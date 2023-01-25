// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.13 <0.9.0;

import { IAdminable } from "@prb/contracts/access/IAdminable.sol";
import { UD60x18, ZERO } from "@prb/math/UD60x18.sol";

import { Errors } from "src/libraries/Errors.sol";
import { Events } from "src/libraries/Events.sol";

import { Comptroller_Test } from "../Comptroller.t.sol";

contract SetProtocolFee_Test is Comptroller_Test {
    /// @dev it should revert.
    function test_RevertWhen_CallerNotAdmin(address eve) external {
        vm.assume(eve != users.admin);

        // Make Eve the caller in this test.
        changePrank(eve);

        // Run the test.
        vm.expectRevert(abi.encodeWithSelector(IAdminable.Adminable_CallerNotAdmin.selector, users.admin, eve));
        comptroller.setProtocolFee(dai, DEFAULT_MAX_FEE);
    }

    modifier callerAdmin() {
        // Make the admin the caller in the rest of this test suite.
        changePrank(users.admin);
        _;
    }

    /// @dev it should re-set the protocol fee.
    function test_SetProtocolFee_SameFee() external callerAdmin {
        comptroller.setProtocolFee({ asset: dai, newProtocolFee: ZERO });
        UD60x18 actualProtocolFee = comptroller.getProtocolFee(dai);
        UD60x18 expectedProtocolFee = ZERO;
        assertEq(actualProtocolFee, expectedProtocolFee);
    }

    modifier newFee() {
        _;
    }

    /// @dev it should set the new protocol fee.
    function testFuzz_SetProtocolFee(UD60x18 newProtocolFee) external callerAdmin newFee {
        newProtocolFee = bound(newProtocolFee, 1, DEFAULT_MAX_FEE);
        comptroller.setProtocolFee({ asset: dai, newProtocolFee: newProtocolFee });

        UD60x18 actualProtocolFee = comptroller.getProtocolFee(dai);
        UD60x18 expectedProtocolFee = newProtocolFee;
        assertEq(actualProtocolFee, expectedProtocolFee);
    }

    /// @dev it should emit a SetProtocolFee event.
    function testFuzz_SetProtocolFee_Event(UD60x18 newProtocolFee) external callerAdmin newFee {
        newProtocolFee = bound(newProtocolFee, 1, DEFAULT_MAX_FEE);
        vm.expectEmit({ checkTopic1: true, checkTopic2: true, checkTopic3: false, checkData: true });
        emit Events.SetProtocolFee({
            admin: users.admin,
            asset: dai,
            oldProtocolFee: ZERO,
            newProtocolFee: newProtocolFee
        });
        comptroller.setProtocolFee({ asset: dai, newProtocolFee: newProtocolFee });
    }
}