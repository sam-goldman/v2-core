// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol";

import { ISablierV2Base } from "src/interfaces/ISablierV2Base.sol";
import { ISablierV2Lockup } from "src/interfaces/ISablierV2Lockup.sol";

import { Dynamic_Shared_Test } from "../../shared/lockup-dynamic/Dynamic.t.sol";
import { Unit_Test } from "../Unit.t.sol";
import { Burn_Unit_Test } from "../lockup/burn/burn.t.sol";
import { Cancel_Unit_Test } from "../lockup/cancel/cancel.t.sol";
import { CancelMultiple_Unit_Test } from "../lockup/cancel-multiple/cancelMultiple.t.sol";
import { ClaimProtocolRevenues_Unit_Test } from "../lockup/claim-protocol-revenues/claimProtocolRevenues.t.sol";
import { GetAsset_Unit_Test } from "../lockup/get-asset/getAsset.t.sol";
import { GetDepositedAmount_Unit_Test } from "../lockup/get-deposited-amount/getDepositedAmount.t.sol";
import { GetEndTime_Unit_Test } from "../lockup/get-end-time/getEndTime.t.sol";
import { ProtocolRevenues_Unit_Test } from "../lockup/protocol-revenues/protocolRevenues.t.sol";
import { GetRecipient_Unit_Test } from "../lockup/get-recipient/getRecipient.t.sol";
import { GetRefundedAmount_Unit_Test } from "../lockup/get-refunded-amount/getRefundedAmount.t.sol";
import { GetSender_Unit_Test } from "../lockup/get-sender/getSender.t.sol";
import { GetStartTime_Unit_Test } from "../lockup/get-start-time/getStartTime.t.sol";
import { GetWithdrawnAmount_Unit_Test } from "../lockup/get-withdrawn-amount/getWithdrawnAmount.t.sol";
import { IsCancelable_Unit_Test } from "../lockup/is-cancelable/isCancelable.t.sol";
import { IsCold_Unit_Test } from "../lockup/is-cold/isCold.t.sol";
import { IsDepleted_Unit_Test } from "../lockup/is-depleted/isDepleted.t.sol";
import { IsStream_Unit_Test } from "../lockup/is-stream/isStream.t.sol";
import { IsWarm_Unit_Test } from "../lockup/is-warm/isWarm.t.sol";
import { RefundableAmountOf_Unit_Test } from "../lockup/refundable-amount-of/refundableAmountOf.t.sol";
import { Renounce_Unit_Test } from "../lockup/renounce/renounce.t.sol";
import { SetComptroller_Unit_Test } from "../lockup/set-comptroller/setComptroller.t.sol";
import { SetNFTDescriptor_Unit_Test } from "../lockup/set-nft-descriptor/setNFTDescriptor.t.sol";
import { StatusOf_Unit_Test } from "../lockup/status-of/statusOf.t.sol";
import { TokenURI_Unit_Test } from "../lockup/token-uri/tokenURI.t.sol";
import { Withdraw_Unit_Test } from "../lockup/withdraw/withdraw.t.sol";
import { WasCanceled_Unit_Test } from "../lockup/was-canceled/wasCanceled.t.sol";
import { WithdrawMax_Unit_Test } from "../lockup/withdraw-max/withdrawMax.t.sol";
import { WithdrawMultiple_Unit_Test } from "../lockup/withdraw-multiple/withdrawMultiple.t.sol";

/*//////////////////////////////////////////////////////////////////////////
                            NON-SHARED ABSTRACT TEST
//////////////////////////////////////////////////////////////////////////*/

/// @title Dynamic_Unit_Test
/// @notice Common testing logic needed across {SablierV2LockupDynamic} unit tests.
abstract contract Dynamic_Unit_Test is Unit_Test, Dynamic_Shared_Test {
    function setUp() public virtual override(Unit_Test, Dynamic_Shared_Test) {
        // Both of these contracts inherit from {Base_Test}, which is fine because multiple inheritance is
        // allowed in Solidity, and {Base_Test-setUp} will only be called once.
        Unit_Test.setUp();
        Dynamic_Shared_Test.setUp();

        // Cast the linear contract as {ISablierV2Base} and {ISablierV2Lockup}.
        base = ISablierV2Lockup(dynamic);
        lockup = ISablierV2Lockup(dynamic);
    }
}

/*//////////////////////////////////////////////////////////////////////////
                                SHARED TESTS
//////////////////////////////////////////////////////////////////////////*/

contract Burn_Dynamic_Unit_Test is Dynamic_Unit_Test, Burn_Unit_Test {
    function setUp() public virtual override(Dynamic_Unit_Test, Burn_Unit_Test) {
        Dynamic_Unit_Test.setUp();
        Burn_Unit_Test.setUp();
    }
}

contract Cancel_Dynamic_Unit_Test is Dynamic_Unit_Test, Cancel_Unit_Test {
    function setUp() public virtual override(Dynamic_Unit_Test, Cancel_Unit_Test) {
        Dynamic_Unit_Test.setUp();
        Cancel_Unit_Test.setUp();
    }
}

contract CancelMultiple_Dynamic_Unit_Test is Dynamic_Unit_Test, CancelMultiple_Unit_Test {
    function setUp() public virtual override(Dynamic_Unit_Test, CancelMultiple_Unit_Test) {
        Dynamic_Unit_Test.setUp();
        CancelMultiple_Unit_Test.setUp();
    }
}

contract ClaimProtocolRevenues_Dynamic_Unit_Test is Dynamic_Unit_Test, ClaimProtocolRevenues_Unit_Test {
    function setUp() public virtual override(Dynamic_Unit_Test, ClaimProtocolRevenues_Unit_Test) {
        Dynamic_Unit_Test.setUp();
        ClaimProtocolRevenues_Unit_Test.setUp();
    }
}

contract GetAsset_Dynamic_Unit_Test is Dynamic_Unit_Test, GetAsset_Unit_Test {
    function setUp() public virtual override(Dynamic_Unit_Test, GetAsset_Unit_Test) {
        Dynamic_Unit_Test.setUp();
        GetAsset_Unit_Test.setUp();
    }
}

contract GetDepositedAmount_Dynamic_Unit_Test is Dynamic_Unit_Test, GetDepositedAmount_Unit_Test {
    function setUp() public virtual override(Dynamic_Unit_Test, GetDepositedAmount_Unit_Test) {
        Dynamic_Unit_Test.setUp();
        GetDepositedAmount_Unit_Test.setUp();
    }
}

contract GetEndTime_Dynamic_Unit_Test is Dynamic_Unit_Test, GetEndTime_Unit_Test {
    function setUp() public virtual override(Dynamic_Unit_Test, GetEndTime_Unit_Test) {
        Dynamic_Unit_Test.setUp();
        GetEndTime_Unit_Test.setUp();
    }
}

contract GetRecipient_Dynamic_Unit_Test is Dynamic_Unit_Test, GetRecipient_Unit_Test {
    function setUp() public virtual override(Dynamic_Unit_Test, GetRecipient_Unit_Test) {
        Dynamic_Unit_Test.setUp();
        GetRecipient_Unit_Test.setUp();
    }
}

contract GetRefundedAmount_Dynamic_Unit_Test is Dynamic_Unit_Test, GetRefundedAmount_Unit_Test {
    function setUp() public virtual override(Dynamic_Unit_Test, GetRefundedAmount_Unit_Test) {
        Dynamic_Unit_Test.setUp();
        GetRefundedAmount_Unit_Test.setUp();
    }
}

contract ProtocolRevenues_Dynamic_Unit_Test is Dynamic_Unit_Test, ProtocolRevenues_Unit_Test {
    function setUp() public virtual override(Dynamic_Unit_Test, ProtocolRevenues_Unit_Test) {
        Dynamic_Unit_Test.setUp();
        ProtocolRevenues_Unit_Test.setUp();
    }
}

contract RefundableAmountOf_Dynamic_Unit_Test is Dynamic_Unit_Test, RefundableAmountOf_Unit_Test {
    function setUp() public virtual override(Dynamic_Unit_Test, RefundableAmountOf_Unit_Test) {
        Dynamic_Unit_Test.setUp();
        RefundableAmountOf_Unit_Test.setUp();
    }
}

contract GetSender_Dynamic_Unit_Test is Dynamic_Unit_Test, GetSender_Unit_Test {
    function setUp() public virtual override(Dynamic_Unit_Test, GetSender_Unit_Test) {
        Dynamic_Unit_Test.setUp();
        GetSender_Unit_Test.setUp();
    }
}

contract GetStartTime_Dynamic_Unit_Test is Dynamic_Unit_Test, GetStartTime_Unit_Test {
    function setUp() public virtual override(Dynamic_Unit_Test, GetStartTime_Unit_Test) {
        Dynamic_Unit_Test.setUp();
        GetStartTime_Unit_Test.setUp();
    }
}

contract GetWithdrawnAmount_Dynamic_Unit_Test is Dynamic_Unit_Test, GetWithdrawnAmount_Unit_Test {
    function setUp() public virtual override(Dynamic_Unit_Test, GetWithdrawnAmount_Unit_Test) {
        Dynamic_Unit_Test.setUp();
        GetWithdrawnAmount_Unit_Test.setUp();
    }
}

contract IsCancelable_Dynamic_Unit_Test is Dynamic_Unit_Test, IsCancelable_Unit_Test {
    function setUp() public virtual override(Dynamic_Unit_Test, IsCancelable_Unit_Test) {
        Dynamic_Unit_Test.setUp();
        IsCancelable_Unit_Test.setUp();
    }
}

contract IsCold_Dynamic_Unit_Test is Dynamic_Unit_Test, IsCold_Unit_Test {
    function setUp() public virtual override(Dynamic_Unit_Test, IsCold_Unit_Test) {
        Dynamic_Unit_Test.setUp();
        IsCold_Unit_Test.setUp();
    }
}

contract IsDepleted_Dynamic_Unit_Test is Dynamic_Unit_Test, IsDepleted_Unit_Test {
    function setUp() public virtual override(Dynamic_Unit_Test, IsDepleted_Unit_Test) {
        Dynamic_Unit_Test.setUp();
        IsDepleted_Unit_Test.setUp();
    }
}

contract IsStream_Dynamic_Unit_Test is Dynamic_Unit_Test, IsStream_Unit_Test {
    function setUp() public virtual override(Dynamic_Unit_Test, IsStream_Unit_Test) {
        Dynamic_Unit_Test.setUp();
        IsStream_Unit_Test.setUp();
    }
}

contract IsWarm_Dynamic_Unit_Test is Dynamic_Unit_Test, IsWarm_Unit_Test {
    function setUp() public virtual override(Dynamic_Unit_Test, IsWarm_Unit_Test) {
        Dynamic_Unit_Test.setUp();
        IsWarm_Unit_Test.setUp();
    }
}

contract Renounce_Dynamic_Unit_Test is Dynamic_Unit_Test, Renounce_Unit_Test {
    function setUp() public virtual override(Dynamic_Unit_Test, Renounce_Unit_Test) {
        Dynamic_Unit_Test.setUp();
        Renounce_Unit_Test.setUp();
    }
}

contract SetComptroller_Dynamic_Unit_Test is Dynamic_Unit_Test, SetComptroller_Unit_Test {
    function setUp() public virtual override(Dynamic_Unit_Test, SetComptroller_Unit_Test) {
        Dynamic_Unit_Test.setUp();
        SetComptroller_Unit_Test.setUp();
    }
}

contract SetNFTDescriptor_Dynamic_Unit_Test is Dynamic_Unit_Test, SetNFTDescriptor_Unit_Test {
    function setUp() public virtual override(Dynamic_Unit_Test, SetNFTDescriptor_Unit_Test) {
        Dynamic_Unit_Test.setUp();
        SetNFTDescriptor_Unit_Test.setUp();
    }
}

contract StatusOf_Dynamic_Unit_Test is Dynamic_Unit_Test, StatusOf_Unit_Test {
    function setUp() public virtual override(Dynamic_Unit_Test, StatusOf_Unit_Test) {
        Dynamic_Unit_Test.setUp();
        StatusOf_Unit_Test.setUp();
    }
}

contract TokenURI_Dynamic_Unit_Test is Dynamic_Unit_Test, TokenURI_Unit_Test {
    function setUp() public virtual override(Dynamic_Unit_Test, TokenURI_Unit_Test) {
        Dynamic_Unit_Test.setUp();
        TokenURI_Unit_Test.setUp();
    }
}

contract WasCanceled_Dynamic_Unit_Test is Dynamic_Unit_Test, WasCanceled_Unit_Test {
    function setUp() public virtual override(Dynamic_Unit_Test, WasCanceled_Unit_Test) {
        Dynamic_Unit_Test.setUp();
        WasCanceled_Unit_Test.setUp();
    }
}

contract Withdraw_Dynamic_Unit_Test is Dynamic_Unit_Test, Withdraw_Unit_Test {
    function setUp() public virtual override(Dynamic_Unit_Test, Withdraw_Unit_Test) {
        Dynamic_Unit_Test.setUp();
        Withdraw_Unit_Test.setUp();
    }
}

contract WithdrawMax_Dynamic_Unit_Test is Dynamic_Unit_Test, WithdrawMax_Unit_Test {
    function setUp() public virtual override(Dynamic_Unit_Test, WithdrawMax_Unit_Test) {
        Dynamic_Unit_Test.setUp();
        WithdrawMax_Unit_Test.setUp();
    }
}

contract WithdrawMultiple_Dynamic_Unit_Test is Dynamic_Unit_Test, WithdrawMultiple_Unit_Test {
    function setUp() public virtual override(Dynamic_Unit_Test, WithdrawMultiple_Unit_Test) {
        Dynamic_Unit_Test.setUp();
        WithdrawMultiple_Unit_Test.setUp();
    }
}