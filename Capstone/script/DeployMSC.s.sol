// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// Imports

import {Script} from "forge-std/Script.sol";
import {MetanaStableCoin} from "../src/MetanaStableCoin.sol";
import {MSCEngine} from "../src/MSCEngine.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployMSC is Script {
    address[] public tokenAddresses;
    address[] public priceFeedAddresses;

    function run() external returns (MetanaStableCoin, MSCEngine, HelperConfig) {
        HelperConfig config = new HelperConfig();

        (address wethUsdPriceFeed, address wbtcPriceFeed, address weth, address wbtc, uint256 deployerKey) =
            config.activeNetworkConfig();

        tokenAddresses = [weth, wbtc];
        priceFeedAddresses = [wethUsdPriceFeed, wbtcPriceFeed];

        vm.startBroadcast(deployerKey);
        MetanaStableCoin msc = new MetanaStableCoin();
        MSCEngine engine = new MSCEngine(tokenAddresses, priceFeedAddresses, address(msc));

        msc.transferOwnership(address(engine));
        vm.stopBroadcast();
        return (msc, engine, config);
    }
}
