// SPDX-License-Identifier: MIT
pragma solidity >=0.8.23;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { UD2x18 } from "@prb/math/src/UD2x18.sol";
import { ud } from "@prb/math/src/UD60x18.sol";
import { SablierV2Comptroller } from "src/SablierV2Comptroller.sol";
import { SablierV2LockupDynamic } from "src/SablierV2LockupDynamic.sol";
import { SablierV2LockupLinear } from "src/SablierV2LockupLinear.sol";
import { Broker, LockupDynamic, LockupLinear } from "src/types/DataTypes.sol";
import { SablierV2NFTDescriptor } from "src/SablierV2NFTDescriptor.sol";

import { PRBTest } from "@prb/test/src/PRBTest.sol";
import { StdCheats } from "forge-std/src/StdCheats.sol";

abstract contract Base_Test is PRBTest, StdCheats {
    address public admin;
    address public sender;
    address public recipient;

    SablierV2Comptroller internal comptroller;
    SablierV2NFTDescriptor internal nftDescriptor;

    ERC20 public dai;
    SablierV2LockupDynamic internal lockupDynamic;
    SablierV2LockupLinear internal lockupLinear;

    function setUp() public {
        admin = makeAddr("admin");
        sender = makeAddr("sender");
        recipient = makeAddr("recipient");

        dai = new ERC20("Dai Stablecoin", "DAI");

        comptroller = new SablierV2Comptroller(admin);
        nftDescriptor = new SablierV2NFTDescriptor();
        lockupDynamic = new SablierV2LockupDynamic(admin, comptroller, nftDescriptor, 300);
        lockupLinear = new SablierV2LockupLinear(admin, comptroller, nftDescriptor);

        vm.deal({ account: sender, newBalance: 1 ether });
        deal({ token: address(dai), to: sender, give: 1_000_000e18 });

        vm.startPrank({ msgSender: sender });
        dai.approve({ spender: address(lockupDynamic), amount: type(uint256).max });
        dai.approve({ spender: address(lockupLinear), amount: type(uint256).max });
    }

    function _now() internal view returns (uint40) {
        return uint40(block.timestamp);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                      LINEAR
    //////////////////////////////////////////////////////////////////////////*/

    function getLinearParams() internal view returns (LockupLinear.CreateWithTimestamps memory) {
        return LockupLinear.CreateWithTimestamps({
            sender: sender,
            recipient: recipient,
            totalAmount: 100e18,
            asset: dai,
            cancelable: true,
            transferable: true,
            range: LockupLinear.Range({ start: _now(), cliff: _now() + 100, end: _now() + 1000 }),
            broker: Broker({ account: address(0), fee: ud(0) })
        });
    }

    /*//////////////////////////////////////////////////////////////////////////
                                      SEGMENTS
    //////////////////////////////////////////////////////////////////////////*/

    function getDynamicParams(uint256 count) internal view returns (LockupDynamic.CreateWithTimestamps memory) {
        return LockupDynamic.CreateWithTimestamps({
            sender: sender,
            recipient: recipient,
            totalAmount: uint128(10e18 * count),
            asset: dai,
            cancelable: true,
            transferable: true,
            segments: getSegments(count),
            startTime: _now(),
            broker: Broker({ account: address(0), fee: ud(0) })
        });
    }

    function getSegments(uint256 count) internal view returns (LockupDynamic.Segment[] memory) {
        LockupDynamic.Segment[] memory _segments = new LockupDynamic.Segment[](count);
        uint40 stepDuration = 100 seconds;
        for (uint40 i = 0; i < count; ++i) {
            _segments[i] = segment();
            _segments[i].timestamp += stepDuration;
            stepDuration += 100; // increment it so that we will have segments timestamps in an ascending order
        }
        return _segments;
    }

    function segment() internal view returns (LockupDynamic.Segment memory) {
        return LockupDynamic.Segment({ amount: 10e18, exponent: UD2x18.wrap(3.14e18), timestamp: _now() });
    }
}
