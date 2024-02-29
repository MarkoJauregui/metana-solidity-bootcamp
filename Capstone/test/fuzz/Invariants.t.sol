// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";

import {DeployMSC} from "../../script/DeployMSC.s.sol";
import {MSCEngine} from "../../src/MSCEngine.sol";
import {MetanaStableCoin} from "../../src/MetanaStableCoin.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {Handler} from "./Handler.t.sol";

contract Invariants is Test {
    DeployMSC deployer;
    MSCEngine engine;
    MetanaStableCoin msc;
    HelperConfig config;
    address weth;
    address wbtc;
    Handler handler;

    function setUp() external {
        deployer = new DeployMSC();
        (msc, engine, config) = deployer.run();
        (,, weth, wbtc,) = config.activeNetworkConfig();

        handler = new Handler(engine, msc);
        targetContract(address(handler));
    }

    function invariant_protocolMustHaveMoreValueThanTotalSupply() public view {
        uint256 totalSupply = msc.totalSupply();
        uint256 totalWethDeposited = IERC20(weth).balanceOf(address(engine));
        uint256 totalBtcDeposited = IERC20(wbtc).balanceOf(address(engine));

        uint256 wethValue = engine.getUsdValue(weth, totalWethDeposited);
        uint256 wbtcValue = engine.getUsdValue(wbtc, totalBtcDeposited);

        console.log("weth value: ", wethValue);
        console.log("wbtc value: ", wbtcValue);
        console.log("total supply: ", totalSupply);

        assert(wethValue + wbtcValue >= totalSupply);
    }
}
