// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.18 <0.9.0;

import { PRBMathCastingUint128 as CastingUint128 } from "@prb/math/casting/Uint128.sol";
import { UD60x18, ud, uUNIT } from "@prb/math/UD60x18.sol";
import { arange } from "solidity-generators/Generators.sol";

import { Constants } from "./Constants.t.sol";
import { Lockup, LockupPro } from "src/types/DataTypes.sol";
import { Utils } from "./Utils.t.sol";

abstract contract Fuzzers is Constants, Utils {
    using CastingUint128 for uint128;

    /*//////////////////////////////////////////////////////////////////////////
                            INTERNAL CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Just like `fuzzSegmentAmountsAndCalculateCreateAmounts` but uses the defaults.
    function fuzzSegmentAmountsAndCalculateCreateAmounts(
        LockupPro.Segment[] memory segments
    ) internal view returns (uint128 totalAmount, Lockup.CreateAmounts memory createAmounts) {
        (totalAmount, createAmounts) = fuzzSegmentAmountsAndCalculateCreateAmounts({
            upperBound: UINT128_MAX,
            segments: segments,
            protocolFee: DEFAULT_PROTOCOL_FEE,
            brokerFee: DEFAULT_BROKER_FEE
        });
    }

    /// @dev Fuzzes the segment amounts and calculate the create amounts (total, deposit, protocol fee, and broker fee).
    function fuzzSegmentAmountsAndCalculateCreateAmounts(
        uint128 upperBound,
        LockupPro.Segment[] memory segments,
        UD60x18 protocolFee,
        UD60x18 brokerFee
    ) internal view returns (uint128 totalAmount, Lockup.CreateAmounts memory createAmounts) {
        uint256 segmentCount = segments.length;
        uint128 maxSegmentAmount = upperBound / uint128(segmentCount * 2);

        // Precompute the first segment amount to prevent zero deposit amounts.
        segments[0].amount = boundUint128(segments[0].amount, 100, maxSegmentAmount);
        uint128 estimatedDepositAmount = segments[0].amount;

        // Fuzz the other segment amounts by bounding from 0.
        unchecked {
            for (uint256 i = 1; i < segmentCount; ) {
                uint128 segmentAmount = boundUint128(segments[i].amount, 0, maxSegmentAmount);
                segments[i].amount = segmentAmount;
                estimatedDepositAmount += segmentAmount;
                i += 1;
            }
        }

        // Calculate the total amount from the approximated deposit amount (recall that the segment amounts summed up
        // must equal the deposit amount) using this formula:
        //
        // $$
        // total = deposit / (1e18 - protocol fee - broker fee)
        // $$
        totalAmount = ud(estimatedDepositAmount)
            .div(ud(uUNIT - protocolFee.intoUint256() - brokerFee.intoUint256()))
            .intoUint128();

        // Calculate the fee amounts.
        createAmounts.protocolFee = ud(totalAmount).mul(protocolFee).intoUint128();
        createAmounts.brokerFee = ud(totalAmount).mul(brokerFee).intoUint128();

        // Here, we account for rounding errors and adjust the estimated deposit amount and the segments. We know that
        // the estimated deposit amount is not greater than the adjusted deposit amount below, because the inverse of
        // the {Helpers-checkAndCalculateFees} function over-expresses the weight of the fees.
        createAmounts.deposit = totalAmount - createAmounts.protocolFee - createAmounts.brokerFee;
        segments[segments.length - 1].amount += (createAmounts.deposit - estimatedDepositAmount);
    }

    /// @dev Fuzzes the deltas and updates the segment milestones.
    function fuzzSegmentDeltas(LockupPro.Segment[] memory segments) internal view returns (uint40[] memory deltas) {
        deltas = new uint40[](segments.length);
        unchecked {
            // Precompute the first segment delta.
            deltas[0] = uint40(bound(segments[0].milestone, 1, 100));
            segments[0].milestone = uint40(block.timestamp) + deltas[0];

            // Bound the deltas so that none is zero and the calculations don't overflow.
            uint256 deltaCount = deltas.length;
            uint40 maxDelta = (MAX_UNIX_TIMESTAMP - deltas[0]) / uint40(deltaCount);
            for (uint256 i = 1; i < deltaCount; ++i) {
                deltas[i] = boundUint40(segments[i].milestone, 1, maxDelta);
                segments[i].milestone = segments[i - 1].milestone + deltas[i];
            }
        }
    }

    /// @dev Fuzzes the segment milestones.
    function fuzzSegmentMilestones(LockupPro.Segment[] memory segments, uint40 startTime) internal view {
        // Precompute the first milestone so that we don't bump into an underflow in the first loop iteration.
        segments[0].milestone = startTime + 1;

        // Return here if there's only one segment to not run into division by zero.
        uint40 segmentCount = uint40(segments.length);
        if (segmentCount == 1) {
            return;
        }

        // Generate `segmentCount` milestones linearly spaced between `startTime + 1` and `MAX_UNIX_TIMESTAMP`.
        uint40 step = (MAX_UNIX_TIMESTAMP - (startTime + 1)) / (segmentCount - 1);
        uint40 halfStep = step / 2;
        uint256[] memory milestones = arange(startTime + 1, MAX_UNIX_TIMESTAMP, step);

        // Fuzz the milestone in a way that preserves its order in the array.
        for (uint256 i = 1; i < segmentCount; ) {
            uint256 milestone = milestones[i];
            milestone = bound(milestone, milestone - halfStep, milestone + halfStep);
            segments[i].milestone = uint40(milestone);
            unchecked {
                i += 1;
            }
        }
    }
}