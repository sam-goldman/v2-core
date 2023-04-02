// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.13;

import { UD60x18, ud } from "@prb/math/UD60x18.sol";

import { Lockup, LockupDynamic, LockupLinear } from "../types/DataTypes.sol";
import { Errors } from "./Errors.sol";

/// @title Helpers
/// @notice Library with helper functions needed across the Sablier V2 contracts.
library Helpers {
    /*//////////////////////////////////////////////////////////////////////////
                             INTERNAL CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Checks that neither fee is greater than `maxFee`, and then calculates the protocol fee amount, the
    /// broker fee amount, and the deposit amount from the total amount.
    function checkAndCalculateFees(
        uint128 totalAmount,
        UD60x18 protocolFee,
        UD60x18 brokerFee,
        UD60x18 maxFee
    )
        internal
        pure
        returns (Lockup.CreateAmounts memory amounts)
    {
        // When the total amount is zero, the fees are also zero.
        if (totalAmount == 0) {
            return Lockup.CreateAmounts(0, 0, 0);
        }

        // Checks: the protocol fee is not greater than `maxFee`.
        if (protocolFee.gt(maxFee)) {
            revert Errors.SablierV2Lockup_ProtocolFeeTooHigh(protocolFee, maxFee);
        }

        // Calculate the protocol fee amount.
        // The cast to uint128 is safe because the maximum fee is hard coded.
        amounts.protocolFee = uint128(ud(totalAmount).mul(protocolFee).intoUint256());

        // Checks: the broker fee is not greater than `maxFee`.
        if (brokerFee.gt(maxFee)) {
            revert Errors.SablierV2Lockup_BrokerFeeTooHigh(brokerFee, maxFee);
        }

        // Calculate the broker fee amount.
        // The cast to uint128 is safe because the maximum fee is hard coded.
        amounts.brokerFee = uint128(ud(totalAmount).mul(brokerFee).intoUint256());

        // Assert that the total amount is strictly greater than the sum of the protocol fee amount and the
        // broker fee amount.
        assert(totalAmount > amounts.protocolFee + amounts.brokerFee);

        // Calculate the deposit amount (the amount to stream, net of fees).
        amounts.deposit = totalAmount - amounts.protocolFee - amounts.brokerFee;
    }

    /// @dev Checks the parameters of the {SablierV2LockupDynamic-_createWithMilestones} function.
    function checkCreateDynamicParams(
        uint128 depositAmount,
        LockupDynamic.Segment[] memory segments,
        uint256 maxSegmentCount,
        uint40 startTime
    )
        internal
        pure
    {
        // Checks: the deposit amount is not zero.
        if (depositAmount == 0) {
            revert Errors.SablierV2Lockup_DepositAmountZero();
        }

        // Check that the segment count is not zero.
        uint256 segmentCount = segments.length;
        if (segmentCount == 0) {
            revert Errors.SablierV2LockupDynamic_SegmentCountZero();
        }

        // Check that the segment count is not greater than the maximum segment count permitted.
        if (segmentCount > maxSegmentCount) {
            revert Errors.SablierV2LockupDynamic_SegmentCountTooHigh(segmentCount);
        }

        // Checks: requirements of segments variables.
        _checkSegments(segments, depositAmount, startTime);
    }

    /// @dev Checks the parameters of the {SablierV2LockupLinear-_createWithRange} function.
    function checkCreateLinearParams(uint128 depositAmount, LockupLinear.Range memory range) internal pure {
        // Checks: the deposit amount is not zero.
        if (depositAmount == 0) {
            revert Errors.SablierV2Lockup_DepositAmountZero();
        }

        // Checks: the start time is less than or equal to the cliff time.
        if (range.start > range.cliff) {
            revert Errors.SablierV2LockupLinear_StartTimeGreaterThanCliffTime(range.start, range.cliff);
        }

        // Checks: the cliff time is strictly less than the end time.
        if (range.cliff >= range.end) {
            revert Errors.SablierV2LockupLinear_CliffTimeNotLessThanEndTime(range.cliff, range.end);
        }
    }

    /// @dev Checks that the segment array counts match, and then adjusts the segments by calculating the milestones.
    function checkDeltasAndCalculateMilestones(LockupDynamic.SegmentWithDelta[] memory segments)
        internal
        view
        returns (LockupDynamic.Segment[] memory segmentsWithMilestones)
    {
        uint256 segmentCount = segments.length;
        segmentsWithMilestones = new LockupDynamic.Segment[](segmentCount);

        // Make the current time the start time of the stream.
        uint40 startTime = uint40(block.timestamp);

        // It is safe to use unchecked arithmetic because {_createWithMilestone} will nonetheless check the soundness
        // of the calculated segment milestones.
        unchecked {
            // Precompute the first segment because of the need to add the start time to the first segment delta.
            segmentsWithMilestones[0] = LockupDynamic.Segment({
                amount: segments[0].amount,
                exponent: segments[0].exponent,
                milestone: startTime + segments[0].delta
            });

            // Copy the segment amounts and exponents, and calculate the segment milestones.
            for (uint256 i = 1; i < segmentCount; ++i) {
                segmentsWithMilestones[i] = LockupDynamic.Segment({
                    amount: segments[i].amount,
                    exponent: segments[i].exponent,
                    milestone: segmentsWithMilestones[i - 1].milestone + segments[i].delta
                });
            }
        }
    }

    /*//////////////////////////////////////////////////////////////////////////
                             PRIVATE CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Checks that:
    ///
    /// 1. The first milestone is greater than or equal to the start time.
    /// 2. The milestones are ordered chronologically.
    /// 3. There are no duplicate milestones.
    /// 4. The deposit amount is equal to the segment amounts summed up.
    function _checkSegments(
        LockupDynamic.Segment[] memory segments,
        uint128 depositAmount,
        uint40 startTime
    )
        private
        pure
    {
        // Checks: the start time is strictly less than the first segment milestone.
        if (startTime >= segments[0].milestone) {
            revert Errors.SablierV2LockupDynamic_StartTimeNotLessThanFirstSegmentMilestone(
                startTime, segments[0].milestone
            );
        }

        // Pre-declare the variables needed in the for loop.
        uint128 segmentAmountsSum;
        uint40 currentMilestone;
        uint40 previousMilestone;

        // Iterate over the segments to sum up the segment amounts and check that the milestones are ordered.
        uint256 index;
        uint256 segmentCount = segments.length;
        for (index = 0; index < segmentCount;) {
            // Add the current segment amount to the sum. Note that this can overflow.
            segmentAmountsSum += segments[index].amount;

            // Check that the current milestone is strictly greater than the previous milestone.
            currentMilestone = segments[index].milestone;
            if (currentMilestone <= previousMilestone) {
                revert Errors.SablierV2LockupDynamic_SegmentMilestonesNotOrdered(
                    index, previousMilestone, currentMilestone
                );
            }

            // Make the current milestone the previous milestone of the next loop iteration.
            previousMilestone = currentMilestone;

            // Increment the for loop iterator.
            unchecked {
                index += 1;
            }
        }

        // Check that the deposit amount is equal to the segment amounts sum.
        if (depositAmount != segmentAmountsSum) {
            revert Errors.SablierV2LockupDynamic_DepositAmountNotEqualToSegmentAmountsSum(
                depositAmount, segmentAmountsSum
            );
        }
    }
}
