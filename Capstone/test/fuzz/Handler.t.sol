// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {MSCEngine} from "../../src/MSCEngine.sol";
import {MetanaStableCoin} from "../../src/MetanaStableCoin.sol";
import {ERC20Mock} from "../mocks/ERC20Mock.sol";

contract Handler is Test {
    MSCEngine engine;
    MetanaStableCoin msc;

    ERC20Mock weth;
    ERC20Mock wbtc;

    uint256 MAX_DEPOSIT_SIZE = type(uint96).max;

    constructor(MSCEngine _mscEngine, MetanaStableCoin _msc) {
        engine = _mscEngine;
        msc = _msc;

        address[] memory collateralTokens = engine.getCollateralTokens();
        weth = ERC20Mock(collateralTokens[0]);
        wbtc = ERC20Mock(collateralTokens[1]);
    }

    function mintDsc(uint256 amount) public {
        (uint256 totalMscMinted, uint256 collateralValueInUsd) = engine.getAccountInformation(msg.sender);
        int256 maxMscToMint = (int256(collateralValueInUsd) / 2) - int256(totalMscMinted);
        if (maxMscToMint < 0) return;

        amount = bound(amount, 0, uint256(maxMscToMint));
        if (amount == 0) return;

        vm.startPrank(msg.sender);
        engine.mintMsc(amount);
        vm.stopPrank();
    }

    function depositColleteral(uint256 collateralSeed, uint256 amountCollateral) public {
        ERC20Mock collateral = _getCollateralFromSeed(collateralSeed);
        amountCollateral = bound(amountCollateral, 1, MAX_DEPOSIT_SIZE);

        vm.startPrank(msg.sender);
        collateral.mint(msg.sender, amountCollateral);
        collateral.approve(address(engine), amountCollateral);
        engine.depositCollateral(address(collateral), amountCollateral);
        vm.stopPrank();
    }

    function redeemCollateral(uint256 collateralSeed, uint256 amountCollateral) public {
        ERC20Mock collateral = _getCollateralFromSeed(collateralSeed);
        uint256 maxCollateralToRedeem = engine.getCollateralBalanceOfUser(address(collateral), msg.sender);
        amountCollateral = bound(amountCollateral, 0, maxCollateralToRedeem);
        if (amountCollateral == 0) {
            return;
        }
        engine.reedemCollateral(address(collateral), amountCollateral);
    }

    function _getCollateralFromSeed(uint256 collateralSeed) private view returns (ERC20Mock) {
        if (collateralSeed % 2 == 0) {
            return weth;
        }
        return wbtc;
    }
}
