// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.13 <0.9.0;

import { IAdminable } from "@prb/contracts/access/IAdminable.sol";
import { UD60x18, ZERO } from "@prb/math/UD60x18.sol";

import { Errors } from "src/libraries/Errors.sol";
import { Events } from "src/libraries/Events.sol";

import { Comptroller_Test } from "../Comptroller.t.sol";

contract GetProtocolFee_Test is Comptroller_Test {
    function setUp() public override {
        Comptroller_Test.setUp();

        // Make the admin the caller in this test suite.
        changePrank(users.admin);
    }

    /// @dev it should return zero.
    function test_GetProtocolFee_ProtocolFeeNotSet() external {
        UD60x18 actualProtocolFee = comptroller.getProtocolFee(dai);
        UD60x18 expectedProtocolFee = ZERO;
        assertEq(actualProtocolFee, expectedProtocolFee);
    }

    modifier protocolFeeSet() {
        comptroller.setProtocolFee(dai, DEFAULT_PROTOCOL_FEE);
        _;
    }

    /// @dev it should return the correct protocol fee.
    function test_GetProtocolFee() external protocolFeeSet {
        UD60x18 actualProtocolFee = comptroller.getProtocolFee(dai);
        UD60x18 expectedProtocolFee = DEFAULT_PROTOCOL_FEE;
        assertEq(actualProtocolFee, expectedProtocolFee);
    }
}