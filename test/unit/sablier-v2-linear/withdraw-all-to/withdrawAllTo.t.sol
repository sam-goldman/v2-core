// solhint-disable max-line-length
// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.13;

import { ISablierV2 } from "@sablier/v2-core/interfaces/ISablierV2.sol";
import { ISablierV2Linear } from "@sablier/v2-core/interfaces/ISablierV2Linear.sol";

import { SablierV2LinearUnitTest } from "../SablierV2LinearUnitTest.t.sol";

contract SablierV2Linear__UnitTest__WithdrawAllTo is SablierV2LinearUnitTest {
    uint256[] internal defaultAmounts;
    uint256[] internal defaultStreamIds;
    address internal toAlice;

    /// @dev A setup function invoked before each test case.
    function setUp() public override {
        super.setUp();

        // Define the default amounts, since most tests need them.
        defaultAmounts.push(WITHDRAW_AMOUNT_DAI);
        defaultAmounts.push(WITHDRAW_AMOUNT_DAI);

        // Create the default streams, since most tests need them.
        defaultStreamIds.push(createDefaultDaiStream());
        defaultStreamIds.push(createDefaultDaiStream());

        // Make the recipient the `msg.sender` in this test suite.
        changePrank(users.recipient);

        // Make Alice the address that will receive the tokens.
        toAlice = users.alice;
    }

    /// @dev it should revert.
    function testCannotWithdrawAllTo__ToZeroAddress() external {
        vm.expectRevert(abi.encodeWithSelector(ISablierV2.SablierV2__WithdrawZeroAddress.selector));
        address toZero = address(0);
        sablierV2Linear.withdrawAllTo(defaultStreamIds, toZero, defaultAmounts);
    }

    modifier ToNonZeroAddress() {
        _;
    }

    /// @dev it should revert.
    function testCannotWithdrawAllTo__ArraysNotEqual() external ToNonZeroAddress {
        uint256[] memory streamIds = new uint256[](2);
        uint256[] memory amounts = new uint256[](1);
        vm.expectRevert(
            abi.encodeWithSelector(
                ISablierV2.SablierV2__WithdrawAllArraysNotEqual.selector,
                streamIds.length,
                amounts.length
            )
        );
        sablierV2Linear.withdrawAllTo(streamIds, toAlice, amounts);
    }

    modifier ArraysEqual() {
        _;
    }

    /// @dev it should do nothing.
    function testCannotWithdrawAllTo__OnlyNonExistentStreams() external ToNonZeroAddress ArraysEqual {
        uint256 nonStreamId = 1729;
        uint256[] memory nonStreamIds = createDynamicArray(nonStreamId);
        uint256[] memory amounts = createDynamicArray(WITHDRAW_AMOUNT_DAI);
        sablierV2Linear.withdrawAllTo(nonStreamIds, toAlice, amounts);
    }

    /// @dev it should make the withdrawals for the existent streams.
    function testCannotWithdrawAllTo__SomeNonExistentStreams() external ToNonZeroAddress ArraysEqual {
        uint256 nonStreamId = 1729;
        uint256[] memory streamIds = createDynamicArray(nonStreamId, defaultStreamIds[0]);

        // Warp to 2,600 seconds after the start time (26% of the default stream duration).
        vm.warp(daiStream.startTime + TIME_OFFSET);

        // Run the test.
        sablierV2Linear.withdrawAllTo(streamIds, toAlice, defaultAmounts);
        ISablierV2Linear.Stream memory queriedStream = sablierV2Linear.getStream(defaultStreamIds[0]);
        uint256 actualWithdrawnAmount = queriedStream.withdrawnAmount;
        uint256 expectedWithdrawnAmount = WITHDRAW_AMOUNT_DAI;
        assertEq(actualWithdrawnAmount, expectedWithdrawnAmount);
    }

    modifier OnlyExistentStreams() {
        _;
    }

    /// @dev it should revert.
    function testCannotWithdrawAllTo__CallerSenderAllStreams()
        external
        ToNonZeroAddress
        ArraysEqual
        OnlyExistentStreams
    {
        // Make the sender the `msg.sender` in this test case.
        changePrank(users.sender);

        // Run the test.
        vm.expectRevert(
            abi.encodeWithSelector(ISablierV2.SablierV2__Unauthorized.selector, defaultStreamIds[0], users.sender)
        );
        sablierV2Linear.withdrawAllTo(defaultStreamIds, toAlice, defaultAmounts);
    }

    /// @dev it should revert.
    function testCannotWithdrawAllTo__CallerThirdPartyAllStreams()
        external
        ToNonZeroAddress
        ArraysEqual
        OnlyExistentStreams
    {
        // Make the sender the `msg.sender` in this test case.
        changePrank(users.sender);

        // Run the test.
        vm.expectRevert(
            abi.encodeWithSelector(ISablierV2.SablierV2__Unauthorized.selector, defaultStreamIds[0], users.sender)
        );
        sablierV2Linear.withdrawAllTo(defaultStreamIds, toAlice, defaultAmounts);
    }

    /// @dev it should revert.
    function testCannotWithdrawAllTo__CallerSenderSomeStreams()
        external
        ToNonZeroAddress
        ArraysEqual
        OnlyExistentStreams
    {
        // Create a stream with the sender as the recipient (reversing their roles).
        changePrank(users.recipient);
        uint256 reversedStreamId = sablierV2Linear.create(
            users.recipient,
            daiStream.sender,
            daiStream.depositAmount,
            daiStream.token,
            daiStream.startTime,
            daiStream.cliffTime,
            daiStream.stopTime,
            daiStream.cancelable
        );

        // Make Eve the sender the caller in the rest of this test case.
        changePrank(users.sender);

        // Warp to 2,600 seconds after the start time (26% of the default stream duration).
        vm.warp(daiStream.startTime + TIME_OFFSET);

        // Run the test.
        uint256[] memory streamIds = createDynamicArray(reversedStreamId, defaultStreamIds[0]);
        vm.expectRevert(
            abi.encodeWithSelector(ISablierV2.SablierV2__Unauthorized.selector, defaultStreamIds[0], users.sender)
        );
        sablierV2Linear.withdrawAllTo(streamIds, toAlice, defaultAmounts);
    }

    /// @dev it should revert.
    function testCannotWithdrawAllTo__CallerThirdPartySomeStreams()
        external
        ToNonZeroAddress
        ArraysEqual
        OnlyExistentStreams
    {
        // Create a stream with Eve as the recipient.
        changePrank(users.sender);
        uint256 eveStreamId = sablierV2Linear.create(
            daiStream.sender,
            users.eve,
            daiStream.depositAmount,
            daiStream.token,
            daiStream.startTime,
            daiStream.cliffTime,
            daiStream.stopTime,
            daiStream.cancelable
        );

        // Make Eve the `msg.sender` the caller in the rest of this test case.
        changePrank(users.eve);

        // Warp to 2,600 seconds after the start time (26% of the default stream duration).
        vm.warp(daiStream.startTime + TIME_OFFSET);

        // Run the test.
        uint256[] memory streamIds = createDynamicArray(eveStreamId, defaultStreamIds[0]);
        vm.expectRevert(
            abi.encodeWithSelector(ISablierV2.SablierV2__Unauthorized.selector, defaultStreamIds[0], users.eve)
        );
        sablierV2Linear.withdrawAllTo(streamIds, toAlice, defaultAmounts);
    }

    modifier CallerRecipient() {
        _;
    }

    /// @dev it should revert.
    function testCannotWithdrawAllTo__SomeAmountsZero()
        external
        ToNonZeroAddress
        ArraysEqual
        OnlyExistentStreams
        CallerRecipient
    {
        // Warp to 2,600 seconds after the start time (26% of the default stream duration).
        vm.warp(daiStream.startTime + TIME_OFFSET);

        // Run the test.
        uint256[] memory amounts = createDynamicArray(WITHDRAW_AMOUNT_DAI, 0);
        vm.expectRevert(abi.encodeWithSelector(ISablierV2.SablierV2__WithdrawAmountZero.selector, defaultStreamIds[1]));
        sablierV2Linear.withdrawAllTo(defaultStreamIds, toAlice, amounts);
    }

    /// @dev it should revert.
    function testCannotWithdrawAllTo__SomeAmountsGreaterThanWithdrawableAmounts()
        external
        ToNonZeroAddress
        ArraysEqual
        OnlyExistentStreams
        CallerRecipient
    {
        // Warp to 2,600 seconds after the start time (26% of the default stream duration).
        vm.warp(daiStream.startTime + TIME_OFFSET);

        // Run the test.
        uint256 withdrawableAmount = WITHDRAW_AMOUNT_DAI;
        uint256 withdrawAmountMaxUint256 = UINT256_MAX;
        uint256[] memory amounts = createDynamicArray(withdrawableAmount, withdrawAmountMaxUint256);
        vm.expectRevert(
            abi.encodeWithSelector(
                ISablierV2.SablierV2__WithdrawAmountGreaterThanWithdrawableAmount.selector,
                defaultStreamIds[1],
                withdrawAmountMaxUint256,
                withdrawableAmount
            )
        );
        sablierV2Linear.withdrawAllTo(defaultStreamIds, toAlice, amounts);
    }

    modifier AllAmountsLessThanOrEqualToWithdrawableAmounts() {
        _;
    }

    /// @dev it should make the withdrawals and update the withdrawn amounts.
    function testWithdrawAllTo__ToRecipient()
        external
        ToNonZeroAddress
        ArraysEqual
        OnlyExistentStreams
        CallerRecipient
        AllAmountsLessThanOrEqualToWithdrawableAmounts
    {
        // Warp to 2,600 seconds after the start time (26% of the default stream duration).
        vm.warp(daiStream.startTime + TIME_OFFSET);

        // Run the test.
        address toRecipient = daiStream.recipient;
        sablierV2Linear.withdrawAllTo(defaultStreamIds, toRecipient, defaultAmounts);
        ISablierV2Linear.Stream memory queriedStream0 = sablierV2Linear.getStream(defaultStreamIds[0]);
        ISablierV2Linear.Stream memory queriedStream1 = sablierV2Linear.getStream(defaultStreamIds[1]);

        uint256 actualWithdrawnAmount0 = queriedStream0.withdrawnAmount;
        uint256 actualWithdrawnAmount1 = queriedStream1.withdrawnAmount;
        uint256 expectedWithdrawnAmount0 = WITHDRAW_AMOUNT_DAI;
        uint256 expectedWithdrawnAmount1 = WITHDRAW_AMOUNT_DAI;

        assertEq(actualWithdrawnAmount0, expectedWithdrawnAmount0);
        assertEq(actualWithdrawnAmount1, expectedWithdrawnAmount1);
    }

    modifier ToThirdParty() {
        _;
    }

    /// @dev it should make the withdrawals and delete the streams.
    function testWithdrawAllTo__AllStreamsEnded()
        external
        ToNonZeroAddress
        ArraysEqual
        OnlyExistentStreams
        CallerRecipient
        AllAmountsLessThanOrEqualToWithdrawableAmounts
        ToThirdParty
    {
        // Warp to the end of the stream.
        vm.warp(daiStream.stopTime);

        // Run the test.
        uint256[] memory amounts = createDynamicArray(daiStream.depositAmount, daiStream.depositAmount);
        sablierV2Linear.withdrawAllTo(defaultStreamIds, toAlice, amounts);

        ISablierV2Linear.Stream memory actualStream0 = sablierV2Linear.getStream(defaultStreamIds[0]);
        ISablierV2Linear.Stream memory actualStream1 = sablierV2Linear.getStream(defaultStreamIds[1]);
        ISablierV2Linear.Stream memory expectedStream;

        assertEq(actualStream0, expectedStream);
        assertEq(actualStream1, expectedStream);
    }

    /// @dev it should emit multiple Withdraw events.
    function testWithdrawAllTo__AllStreamsEnded__Events()
        external
        ToNonZeroAddress
        ArraysEqual
        OnlyExistentStreams
        CallerRecipient
        AllAmountsLessThanOrEqualToWithdrawableAmounts
        ToThirdParty
    {
        // Warp to the end of the stream.
        vm.warp(daiStream.stopTime);

        // Run the test.
        uint256 withdrawAmount = daiStream.depositAmount;

        vm.expectEmit(true, true, false, true);
        emit Withdraw(defaultStreamIds[0], toAlice, withdrawAmount);
        vm.expectEmit(true, true, false, true);
        emit Withdraw(defaultStreamIds[1], toAlice, withdrawAmount);

        uint256[] memory amounts = createDynamicArray(withdrawAmount, withdrawAmount);
        sablierV2Linear.withdrawAllTo(defaultStreamIds, toAlice, amounts);
    }

    /// @dev it should make the withdrawals and update the withdrawn amounts.
    function testWithdrawAllTo__AllStreamsOngoing()
        external
        ToNonZeroAddress
        ArraysEqual
        OnlyExistentStreams
        CallerRecipient
        AllAmountsLessThanOrEqualToWithdrawableAmounts
        ToThirdParty
    {
        // Warp to 2,600 seconds after the start time (26% of the default stream duration).
        vm.warp(daiStream.startTime + TIME_OFFSET);

        // Run the test.
        sablierV2Linear.withdrawAllTo(defaultStreamIds, toAlice, defaultAmounts);
        ISablierV2Linear.Stream memory queriedStream0 = sablierV2Linear.getStream(defaultStreamIds[0]);
        ISablierV2Linear.Stream memory queriedStream1 = sablierV2Linear.getStream(defaultStreamIds[1]);

        uint256 actualWithdrawnAmount0 = queriedStream0.withdrawnAmount;
        uint256 actualWithdrawnAmount1 = queriedStream1.withdrawnAmount;
        uint256 expectedWithdrawnAmount0 = WITHDRAW_AMOUNT_DAI;
        uint256 expectedWithdrawnAmount1 = WITHDRAW_AMOUNT_DAI;

        assertEq(actualWithdrawnAmount0, expectedWithdrawnAmount0);
        assertEq(actualWithdrawnAmount1, expectedWithdrawnAmount1);
    }

    /// @dev it should emit multiple Withdraw events.
    function testWithdrawAllTo__AllStreamsOngoing__Events()
        external
        ToNonZeroAddress
        ArraysEqual
        OnlyExistentStreams
        CallerRecipient
        AllAmountsLessThanOrEqualToWithdrawableAmounts
        ToThirdParty
    {
        // Warp to 2,600 seconds after the start time (26% of the default stream duration).
        vm.warp(daiStream.startTime + TIME_OFFSET);

        // Run the test.
        uint256 withdrawAmount = WITHDRAW_AMOUNT_DAI;

        vm.expectEmit(true, true, false, true);
        emit Withdraw(defaultStreamIds[0], toAlice, withdrawAmount);
        vm.expectEmit(true, true, false, true);
        emit Withdraw(defaultStreamIds[1], toAlice, withdrawAmount);

        sablierV2Linear.withdrawAllTo(defaultStreamIds, toAlice, defaultAmounts);
    }

    /// @dev it should make the withdrawals, delete the ended streams and update the withdrawn amounts
    function testWithdrawAllTo__SomeStreamsEndedSomeStreamsOngoing()
        external
        ToNonZeroAddress
        ArraysEqual
        OnlyExistentStreams
        CallerRecipient
        AllAmountsLessThanOrEqualToWithdrawableAmounts
        ToThirdParty
    {
        // Create the ended dai stream.
        changePrank(daiStream.sender);
        uint256 earlyStopTime = daiStream.startTime + TIME_OFFSET;
        uint256 endedDaiStreamId = sablierV2Linear.create(
            daiStream.sender,
            daiStream.recipient,
            daiStream.depositAmount,
            daiStream.token,
            daiStream.startTime,
            daiStream.cliffTime,
            earlyStopTime,
            daiStream.cancelable
        );
        changePrank(daiStream.recipient);

        // Use the first default stream as the ongoing daiStream.
        uint256 ongoingStreamId = defaultStreamIds[0];

        // Warp to the end of the early daiStream.
        vm.warp(earlyStopTime);

        // Run the test.
        uint256 endedWithdrawAmount = daiStream.depositAmount;
        uint256 ongoingWithdrawAmount = WITHDRAW_AMOUNT_DAI;
        uint256[] memory streamIds = createDynamicArray(endedDaiStreamId, ongoingStreamId);
        uint256[] memory amounts = createDynamicArray(endedWithdrawAmount, ongoingWithdrawAmount);
        sablierV2Linear.withdrawAllTo(streamIds, toAlice, amounts);

        ISablierV2Linear.Stream memory actualStream0 = sablierV2Linear.getStream(endedDaiStreamId);
        ISablierV2Linear.Stream memory expectedStream0;
        assertEq(actualStream0, expectedStream0);

        ISablierV2Linear.Stream memory queriedStream1 = sablierV2Linear.getStream(ongoingStreamId);
        uint256 actualWithdrawnAmount1 = queriedStream1.withdrawnAmount;
        uint256 expectedWithdrawnAmount1 = WITHDRAW_AMOUNT_DAI;
        assertEq(actualWithdrawnAmount1, expectedWithdrawnAmount1);
    }

    /// @dev it should emit Withdraw events.
    function testWithdrawAllTo__SomeStreamsEndedSomeStreamsOngoing__Events()
        external
        ToNonZeroAddress
        ArraysEqual
        OnlyExistentStreams
        CallerRecipient
        AllAmountsLessThanOrEqualToWithdrawableAmounts
        ToThirdParty
    {
        // Create the ended dai stream.
        changePrank(daiStream.sender);
        uint256 earlyStopTime = daiStream.startTime + TIME_OFFSET;
        uint256 endedDaiStreamId = sablierV2Linear.create(
            daiStream.sender,
            daiStream.recipient,
            daiStream.depositAmount,
            daiStream.token,
            daiStream.startTime,
            daiStream.cliffTime,
            earlyStopTime,
            daiStream.cancelable
        );
        changePrank(daiStream.recipient);

        // Use the first default stream as the ongoing daiStream.
        uint256 ongoingStreamId = defaultStreamIds[0];

        // Warp to the end of the early daiStream.
        vm.warp(earlyStopTime);

        // Run the test.
        uint256 endedWithdrawAmount = daiStream.depositAmount;
        uint256 ongoingWithdrawAmount = WITHDRAW_AMOUNT_DAI;

        vm.expectEmit(true, true, false, true);
        emit Withdraw(endedDaiStreamId, toAlice, endedWithdrawAmount);
        vm.expectEmit(true, true, false, true);
        emit Withdraw(ongoingStreamId, toAlice, ongoingWithdrawAmount);

        uint256[] memory streamIds = createDynamicArray(endedDaiStreamId, ongoingStreamId);
        uint256[] memory amounts = createDynamicArray(endedWithdrawAmount, ongoingWithdrawAmount);
        sablierV2Linear.withdrawAllTo(streamIds, toAlice, amounts);
    }
}
