// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.13 <0.9.0;

import { ISablierV2LockupSender } from "src/interfaces/hooks/ISablierV2LockupSender.sol";
import { ISablierV2Lockup } from "src/interfaces/ISablierV2Lockup.sol";

contract ReentrantSender is ISablierV2LockupSender {
    function onStreamCanceled(
        uint256 streamId,
        address caller,
        uint128 recipientAmount,
        uint128 senderAmount
    ) external {
        streamId;
        caller;
        recipientAmount;
        senderAmount;
        ISablierV2Lockup(msg.sender).cancel(streamId);
    }
}