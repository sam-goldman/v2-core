// SPDX-License-Identifier: MIT
pragma solidity >=0.8.23;

import { LockupDynamic, LockupLinear } from "src/types/DataTypes.sol";

import { console2 } from "forge-std/src/console2.sol";

import { Base_Test } from "./Base.t.sol";

contract Benchmarks is Base_Test {
    /*//////////////////////////////////////////////////////////////////////////
                                  CREATE FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    // Note: we start from the second stream (index = 1), because the first stream will consume more gas the second
    // stream, even if they both have a single segment/tranche. The first stream ever created involves writing
    // multiple zero slots to non-zero values. This is we start from an index of 1.

    function test_CreateWithTimestamps_LockupDynamic_GasTests() external {
        uint8[13] memory segmentCounts = [1, 2, 4, 6, 8, 12, 24, 36, 48, 60, 72, 96, 120];
        uint256[] memory beforeGas = new uint256[](segmentCounts.length);
        uint256[] memory afterGas = new uint256[](segmentCounts.length);

        LockupDynamic.CreateWithTimestamps memory params;
        for (uint256 i = 0; i < segmentCounts.length; ++i) {
            params = getDynamicParams(segmentCounts[i]);
            beforeGas[i] = gasleft();
            lockupDynamic.createWithTimestamps(params);
            afterGas[i] = gasleft();
        }

        for (uint256 i = 1; i < segmentCounts.length; ++i) {
            uint256 gasUsed = beforeGas[i] - afterGas[i];
            console2.log(
                "Gas used for createWithTimestamps in LockupDynamic: ",
                gasUsed,
                " with segments length: ",
                segmentCounts[i]
            );
        }
    }

    function test_CreateWithTimestamps_LockupLinear_GasTests() external {
        uint256 beforeGas;
        uint256 afterGas;

        LockupLinear.CreateWithTimestamps memory params;
        params = getLinearParams();
        lockupLinear.createWithTimestamps(params);

        beforeGas = gasleft();
        lockupLinear.createWithTimestamps(params);
        afterGas = gasleft();

        uint256 gasUsed = beforeGas - afterGas;
        console2.log("Gas used for createWithTimestamps in LockupLinear: ", gasUsed);
    }
}
