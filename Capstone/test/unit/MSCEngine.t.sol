// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {DeployMSC} from "../../script/DeployMSC.s.sol";
import {MetanaStableCoin} from "../../src/MetanaStableCoin.sol";
import {MSCEngine} from "../../src/MSCEngine.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {ERC20Mock} from "../mocks/ERC20Mock.sol";
import {MockV3Aggregator} from "../mocks/MockV3Aggregator.sol";

contract MSCEngineTest is Test {
    DeployMSC deployer;
    MetanaStableCoin msc;
    MSCEngine engine;
    HelperConfig config;
    address ethUsdPriceFeed;
    address weth;
    address btcUsdPriceFeed;
    address wbtc;

    address public USER = makeAddr("user");
    uint256 public constant AMOUNT_COLLATERAL = 10 ether;
    uint256 public constant STARTING_ERC20_BALANCE = 10 ether;
    uint256 public constant MIN_HEALTH_FACTOR = 1e18;
    uint256 public constant LIQUIDATION_THRESHOLD = 50;

    uint256 amountCollateral = 10 ether;
    uint256 amountToMint = 100 ether;

    // Liquidation
    address public liquidator = makeAddr("liquidator");
    uint256 public collateralToCover = 20 ether;

    function setUp() public {
        deployer = new DeployMSC();
        (msc, engine, config) = deployer.run();
        (ethUsdPriceFeed, btcUsdPriceFeed, weth, wbtc,) = config.activeNetworkConfig();

        ERC20Mock(weth).mint(USER, STARTING_ERC20_BALANCE);
    }

    /////////////////////////
    //  Constructor Tests //
    ////////////////////////
    address[] public tokenAddresses;
    address[] public priceFeedAddresses;

    function testRevertsIfTokenLengthDoesntMatchPriceFeeds() public {
        tokenAddresses.push(weth);
        priceFeedAddresses.push(ethUsdPriceFeed);
        priceFeedAddresses.push(btcUsdPriceFeed);

        vm.expectRevert(MSCEngine.MSCEngine__TokenAddressesAndPriceFeedsDoNotMatchLength.selector);
        new MSCEngine(tokenAddresses, priceFeedAddresses, address(msc));
    }

    ///////////////////
    //  Price Tests //
    //////////////////

    function testGetUsdValue() public {
        uint256 ethAmount = 15e18;
        uint256 expectedUsd = 30000e18;
        uint256 actualUsd = engine.getUsdValue(weth, ethAmount);
        assertEq(expectedUsd, actualUsd);
    }

    function testGetTokenAmountFromUsd() public {
        uint256 usdAmount = 100 ether;
        uint256 expectedWeth = 0.05 ether;
        uint256 actualWeth = engine.getTokenAmountFromUsd(weth, usdAmount);
        assertEq(expectedWeth, actualWeth);
    }
    ////////////////////////
    // Deposit Collateral //
    ////////////////////////

    modifier depositedCollateral() {
        vm.startPrank(USER);
        ERC20Mock(weth).approve(address(engine), AMOUNT_COLLATERAL);
        engine.depositCollateral(weth, AMOUNT_COLLATERAL);
        vm.stopPrank();
        _;
    }

    function testRevertsIfCollateralIsZero() public {
        vm.startPrank(USER);
        ERC20Mock(weth).approve(address(engine), AMOUNT_COLLATERAL);

        vm.expectRevert(MSCEngine.MSCEngine__NeedsMoreThanZero.selector);
        engine.depositCollateral(weth, 0);
        vm.stopPrank();
    }

    function testRevertsWithUnapprovedCollateral() public {
        ERC20Mock ranToken = new ERC20Mock("RAN", "RAN", USER, AMOUNT_COLLATERAL);
        vm.startPrank(USER);
        vm.expectRevert(MSCEngine.MSCEngine__TokenNotAllowed.selector);
        engine.depositCollateral(address(ranToken), AMOUNT_COLLATERAL);
        vm.stopPrank();
    }

    function testCanDepositCollateralAndGetAccountInfo() public depositedCollateral {
        (uint256 totalMscMinted, uint256 collateralValueInUsd) = engine.getAccountInformation(USER);

        uint256 expectedTotalMscMinted = 0;
        uint256 expectedDepositAmount = engine.getTokenAmountFromUsd(weth, collateralValueInUsd);
        assertEq(totalMscMinted, expectedTotalMscMinted);
        assertEq(AMOUNT_COLLATERAL, expectedDepositAmount);
    }

    function testCanDepositCollateralWithoutMinting() public depositedCollateral {
        uint256 userBalance = msc.balanceOf(USER);
        assertEq(userBalance, 0);
    }

    //Minting
    function testMintMscSuccessfully() public depositedCollateral {
        uint256 amountMscToMint = 500; // Assuming a scenario where this is within the allowed limit
        vm.startPrank(USER);
        engine.mintMsc(amountMscToMint);
        uint256 balanceMsc = msc.balanceOf(USER);
        assertEq(balanceMsc, amountMscToMint, "User should have minted MSC");
        vm.stopPrank();
    }

    function testRevertsIfMintAmountIsZero() public {
        vm.startPrank(USER);
        ERC20Mock(weth).approve(address(engine), AMOUNT_COLLATERAL);
        engine.depositCollateralAndMintMsc(weth, amountCollateral, amountToMint);
        vm.expectRevert(MSCEngine.MSCEngine__NeedsMoreThanZero.selector);
        engine.mintMsc(0);
        vm.stopPrank();
    }

    function testCanMintMsc() public depositedCollateral {
        vm.prank(USER);
        engine.mintMsc(amountToMint);

        uint256 userBalance = msc.balanceOf(USER);
        assertEq(userBalance, amountToMint);
    }

    function testRevertIfMintAmountBreaksHealthFactor() public depositedCollateral {
        (, int256 price,,,) = MockV3Aggregator(ethUsdPriceFeed).latestRoundData();
        amountToMint = (amountCollateral * uint256(price) * engine.getAdditionalFeedPrecision()) / engine.getPrecision();

        vm.startPrank(USER);

        uint256 expectedHealthFactor =
            engine.calculateHealthFactor(amountToMint, engine.getUsdValue(weth, amountCollateral));
        vm.expectRevert(abi.encodeWithSelector(MSCEngine.MSCEngine__BreaksHealthFactor.selector, expectedHealthFactor));
        engine.mintMsc(amountToMint);
        vm.stopPrank();
    }

    //////////////////////////////////////
    // depositCollateralAndMintDsc tests//
    //////////////////////////////////////

    function testRevertsIfMintedMscBreaksHealthFactor() public {
        (, int256 price,,,) = MockV3Aggregator(ethUsdPriceFeed).latestRoundData();
        amountToMint = (amountCollateral * uint256(price) * engine.getAdditionalFeedPrecision()) / engine.getPrecision();
        vm.startPrank(USER);
        ERC20Mock(weth).approve(address(engine), amountCollateral);

        uint256 expectedHealthFactor =
            engine.calculateHealthFactor(amountToMint, engine.getUsdValue(weth, amountCollateral));
        vm.expectRevert(abi.encodeWithSelector(MSCEngine.MSCEngine__BreaksHealthFactor.selector, expectedHealthFactor));
        engine.depositCollateralAndMintMsc(weth, amountCollateral, amountToMint);
        vm.stopPrank();
    }

    modifier depositedCollateralAndMintedMsc() {
        vm.startPrank(USER);
        ERC20Mock(weth).approve(address(engine), amountCollateral);
        engine.depositCollateralAndMintMsc(weth, amountCollateral, amountToMint);
        vm.stopPrank();
        _;
    }

    function testCanMintWithDepositedCollateral() public depositedCollateralAndMintedMsc {
        uint256 userBalance = msc.balanceOf(USER);
        assertEq(userBalance, amountToMint);
    }

    ///////////////////
    // burnMsc tests//
    //////////////////

    function testRevertsIfBurnAmountIsZero() public {
        vm.startPrank(USER);
        ERC20Mock(weth).approve(address(engine), amountCollateral);
        engine.depositCollateralAndMintMsc(weth, amountCollateral, amountToMint);
        vm.expectRevert(MSCEngine.MSCEngine__NeedsMoreThanZero.selector);
        engine.burnMsc(0);
        vm.stopPrank();
    }

    function testCantBurnMoreThanUserHas() public {
        vm.prank(USER);
        vm.expectRevert();
        engine.burnMsc(1);
    }

    function testCanBurnMsc() public depositedCollateralAndMintedMsc {
        vm.startPrank(USER);
        msc.approve(address(engine), amountToMint);
        engine.burnMsc(amountToMint);
        vm.stopPrank();

        uint256 userBalance = msc.balanceOf(USER);
        assertEq(userBalance, 0);
    }

    ////////////////////////////
    // reedeemCollateral tests//
    ///////////////////////////

    function testRevertsIfRedeemAmountIsZero() public {
        vm.startPrank(USER);
        ERC20Mock(weth).approve(address(engine), amountCollateral);
        engine.depositCollateralAndMintMsc(weth, amountCollateral, amountToMint);
        vm.expectRevert(MSCEngine.MSCEngine__NeedsMoreThanZero.selector);
        engine.reedemCollateral(weth, 0);
        vm.stopPrank();
    }

    function testCanReedeemCollateral() public depositedCollateral {
        vm.startPrank(USER);
        engine.reedemCollateral(weth, amountCollateral);
        uint256 userBalance = ERC20Mock(weth).balanceOf(USER);
        assertEq(userBalance, amountCollateral);
        vm.stopPrank();
    }

    //////////////////////////////////
    // reedeemCollateralForMsc tests//
    //////////////////////////////////

    function testMustRedeemMoreThanZero() public depositedCollateralAndMintedMsc {
        vm.startPrank(USER);
        msc.approve(address(engine), amountToMint);
        vm.expectRevert(MSCEngine.MSCEngine__NeedsMoreThanZero.selector);
        engine.reedemCollateralForMsc(weth, 0, amountToMint);
        vm.stopPrank();
    }

    function testCanReedeemDepositedCollateral() public {
        vm.startPrank(USER);
        ERC20Mock(weth).approve(address(engine), amountCollateral);
        engine.depositCollateralAndMintMsc(weth, amountCollateral, amountToMint);
        msc.approve(address(engine), amountToMint);
        engine.reedemCollateralForMsc(weth, amountCollateral, amountToMint);

        vm.stopPrank();

        uint256 userBalance = msc.balanceOf(USER);
        assertEq(userBalance, 0);
    }

    ///////////////////////
    // healthFactor tests//
    ///////////////////////

    function testProperlyReportsHealthFactor() public depositedCollateralAndMintedMsc {
        uint256 expectedHealthFactor = 100 ether;
        uint256 healthFactor = engine.getHealthFactor(USER);

        assertEq(healthFactor, expectedHealthFactor);
    }

    function testHealthFactorCanGoBelowOne() public depositedCollateralAndMintedMsc {
        int256 ethUsdUpdatedPrice = 18e8;

        MockV3Aggregator(ethUsdPriceFeed).updateAnswer(ethUsdUpdatedPrice);

        uint256 userHealthFactor = engine.getHealthFactor(USER);

        assert(userHealthFactor == 0.9 ether);
    }

    ///////////////////////
    // liquidation tests//
    ///////////////////////

    function testCantLiquidateGoodHealthFactor() public depositedCollateralAndMintedMsc {
        ERC20Mock(weth).mint(liquidator, collateralToCover);

        vm.startPrank(liquidator);
        ERC20Mock(weth).approve(address(engine), collateralToCover);
        engine.depositCollateralAndMintMsc(weth, collateralToCover, amountToMint);
        msc.approve(address(engine), amountToMint);

        vm.expectRevert(MSCEngine.MSCEngine__HealthyHealthFactor.selector);
        engine.liquidate(weth, USER, amountToMint);
        vm.stopPrank();
    }

    modifier liquidated() {
        vm.startPrank(USER);
        ERC20Mock(weth).approve(address(engine), amountCollateral);
        engine.depositCollateralAndMintMsc(weth, amountCollateral, amountToMint);
        vm.stopPrank();

        int256 ethUsdUpdatedPrice = 18e8;
        MockV3Aggregator(ethUsdPriceFeed).updateAnswer(ethUsdUpdatedPrice);
        uint256 userHealthFactor = engine.getHealthFactor(USER);

        vm.startPrank(liquidator);
        ERC20Mock(weth).mint(liquidator, collateralToCover);
        ERC20Mock(weth).approve(address(engine), collateralToCover);
        engine.depositCollateralAndMintMsc(weth, collateralToCover, amountToMint);
        msc.approve(address(engine), amountToMint);
        engine.liquidate(weth, USER, amountToMint);
        vm.stopPrank();
        _;
    }

    function testLiquidationPayoutIsCorrect() public liquidated {
        uint256 liquidatorWethBalance = ERC20Mock(weth).balanceOf(liquidator);
        uint256 expectedWeth = engine.getTokenAmountFromUsd(weth, amountToMint)
            + (engine.getTokenAmountFromUsd(weth, amountToMint) / engine.getLiquidationBonus());
        uint256 hardCodedExpected = 6111111111111111110;
        assertEq(liquidatorWethBalance, hardCodedExpected);
        assertEq(liquidatorWethBalance, expectedWeth);
    }

    function testUserStillHasSomeEthAfterLiquidation() public liquidated {
        uint256 amountLiquidated = engine.getTokenAmountFromUsd(weth, amountToMint)
            + (engine.getTokenAmountFromUsd(weth, amountToMint) / engine.getLiquidationBonus());
        uint256 usdAmountLiquidated = engine.getUsdValue(weth, amountLiquidated);
        uint256 expectedUserCollateralValueInUsd = engine.getUsdValue(weth, amountCollateral) - (usdAmountLiquidated);

        (, uint256 userCollateralValueInUsd) = engine.getAccountInformation(USER);
        uint256 hardCodedExpectedValue = 70000000000000000020;
        assertEq(userCollateralValueInUsd, expectedUserCollateralValueInUsd);
        assertEq(userCollateralValueInUsd, hardCodedExpectedValue);
    }

    function testLiquidatorTakesOnUsersDebt() public liquidated {
        (uint256 liquidatorMscMinted,) = engine.getAccountInformation(liquidator);
        assertEq(liquidatorMscMinted, amountToMint);
    }

    function testUserHasNoMoreDebt() public liquidated {
        (uint256 userMscMinted,) = engine.getAccountInformation(USER);
        assertEq(userMscMinted, 0);
    }

    ////////////////////////////////
    // View & Pure functions tests//
    ////////////////////////////////

    function testGetCollateralTokenPriceFeed() public {
        address priceFeed = engine.getCollateralTokenPriceFeed(weth);
        assertEq(priceFeed, ethUsdPriceFeed);
    }

    function testGetCollateralTokens() public {
        address[] memory collateralTokens = engine.getCollateralTokens();
        assertEq(collateralTokens[0], weth);
    }

    function testGetMinHealthFactor() public {
        uint256 minHealthFactor = engine.getMinHealthFactor();
        assertEq(minHealthFactor, MIN_HEALTH_FACTOR);
    }

    function testGetAccountCollateralValueFromInformation() public depositedCollateral {
        (, uint256 collateralValue) = engine.getAccountInformation(USER);
        uint256 expectedCollateralValue = engine.getUsdValue(weth, amountCollateral);
        assertEq(collateralValue, expectedCollateralValue);
    }

    function testGetCollateralBalanceOfUser() public {
        vm.startPrank(USER);
        ERC20Mock(weth).approve(address(engine), amountCollateral);
        engine.depositCollateral(weth, amountCollateral);
        vm.stopPrank();
        uint256 collateralBalance = engine.getCollateralBalanceOfUser(USER, weth);
        assertEq(collateralBalance, amountCollateral);
    }

    function testGetAccountCollateralValue() public {
        vm.startPrank(USER);
        ERC20Mock(weth).approve(address(engine), amountCollateral);
        engine.depositCollateral(weth, amountCollateral);
        vm.stopPrank();

        uint256 collateralValue = engine.getAccountCollateralValue(USER);
        uint256 expectedCollateralValue = engine.getUsdValue(weth, amountCollateral);
        assertEq(collateralValue, expectedCollateralValue);
    }

    function testGetMsc() public {
        address mscAddress = engine.getMsc();
        assertEq(mscAddress, address(msc));
    }
}
