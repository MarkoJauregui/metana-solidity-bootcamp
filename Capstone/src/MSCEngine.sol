// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// Imports
//---------------------------
import {MetanaStableCoin} from "./MetanaStableCoin.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/**
 * @title MSCEngine
 * @author Marko Jauregui
 *  Minimal stable coin system to maintain a 1 MSC = 1$ peg.
 *  Similar to DAI if DAI had no governance and no fees.
 *  Always OverCollateralized with wETH & wBTC
 * @notice This contract handles all the logic for mining and reediming MSC tokens, as well as depositing & withdrawing collateral.
 * @notice Contract loosely based on MakerDAO DSS (DAI) system.
 */
contract MSCEngine is ReentrancyGuard {
    ////////////
    // Errors //
    ////////////
    error MSCEngine__NeedsMoreThanZero();
    error MSCEngine__TokenAddressesAndPriceFeedsDoNotMatchLength();
    error MSCEngine__TokenNotAllowed();
    error MSCEngine__TransferFailed();
    error MSCEngine__BreaksHealthFactor(uint256 userHealthFactor);
    error MSCEngine__MintFailed();
    error MSCEngine__HealthyHealthFactor();
    error MSCEngine__HealthFactorNotImproved();

    ////////////////////////
    //  State Variables   //
    ///////////////////////
    uint256 private constant ADDITIONAL_FEED_PRECISION = 1e10;
    uint256 private constant DECIMAL_PRECISION = 1e18;
    uint256 private constant LIQUIDATION_THRESHOLD = 50; //200% overcollateralized
    uint256 private constant LIQUIDATION_PRECISION = 100;
    uint256 private constant MIN_HEALTH_FACTOR = 1e18;
    uint256 private constant LIQUIDATION_BONUS = 10; // 10% bonus

    mapping(address token => address priceFeed) private s_priceFeeds;
    mapping(address user => mapping(address token => uint256 amount)) private s_collateralDeposited;
    mapping(address user => uint256 amountMscMinted) private s_MSCMinted;
    address[] private s_collateralTokens;

    MetanaStableCoin private immutable i_msc;

    ////////////
    // Events //
    ///////////
    event CollateralDeposited(
        address indexed sender, address indexed tokenCollateralAddress, uint256 indexed amountCollateral
    );
    event CollateralReedeemed(
        address indexed reedeemedFrom,
        address indexed reedeemedTo,
        address indexed tokenCollateralAddress,
        uint256 amountCollateral
    );

    ///////////////
    // Modifiers //
    ///////////////
    modifier moreThanZero(uint256 amount) {
        if (amount == 0) {
            revert MSCEngine__NeedsMoreThanZero();
        }
        _;
    }

    modifier isAllowedToken(address token) {
        if (s_priceFeeds[token] == address(0)) {
            revert MSCEngine__TokenNotAllowed();
        }
        _;
    }

    ///////////////
    // Functions //
    ///////////////

    constructor(address[] memory tokenAddresses, address[] memory priceFeedAddresses, address mscAddress) {
        if (tokenAddresses.length != priceFeedAddresses.length) {
            revert MSCEngine__TokenAddressesAndPriceFeedsDoNotMatchLength();
        }

        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            s_priceFeeds[tokenAddresses[i]] = priceFeedAddresses[i];
            s_collateralTokens.push(tokenAddresses[i]);
        }

        i_msc = MetanaStableCoin(mscAddress);
    }

    ////////////////////////
    // External Functions //
    ///////////////////////

    /**
     *
     * @param tokenCollateralAddress The address of the token to deposit as collateral
     * @param amountCollateral The amount of collateral to deposit
     * @param amountMscToMint The amount of Metana Stable coin to mint
     * @notice This function takes care of both depositing collateral and minting MSC in one go.
     */
    function depositCollateralAndMintMsc(
        address tokenCollateralAddress,
        uint256 amountCollateral,
        uint256 amountMscToMint
    ) external {
        depositCollateral(tokenCollateralAddress, amountCollateral);
        mintMsc(amountMscToMint);
    }

    /**
     * @notice follows CEI (Checks, Effects & Interactions)
     * @param tokenCollateralAddress The address of the token to deposit as collateral
     * @param amountCollateral The amount of collateral tokens you want to deposit.
     */
    function depositCollateral(address tokenCollateralAddress, uint256 amountCollateral)
        public
        isAllowedToken(tokenCollateralAddress)
        nonReentrant
        moreThanZero(amountCollateral)
    {
        s_collateralDeposited[msg.sender][tokenCollateralAddress] += amountCollateral;
        emit CollateralDeposited(msg.sender, tokenCollateralAddress, amountCollateral);
        bool success = IERC20(tokenCollateralAddress).transferFrom(msg.sender, address(this), amountCollateral);
        if (!success) revert MSCEngine__TransferFailed();
    }

    /**
     *
     * @param tokenCollateralAddress The collateral address to redeem
     * @param amountCollateral The amount of collateral to reedem
     * @param amountMscToBurn The amount of MSC to burn
     */
    function reedemCollateralForMsc(address tokenCollateralAddress, uint256 amountCollateral, uint256 amountMscToBurn)
        external
    {
        burnMsc(amountMscToBurn);
        reedemCollateral(tokenCollateralAddress, amountCollateral);
    }

    function reedemCollateral(address tokenCollateralAddress, uint256 amountCollateral)
        public
        moreThanZero(amountCollateral)
        nonReentrant
    {
        _redeemCollateral(tokenCollateralAddress, amountCollateral, msg.sender, msg.sender);
        _revertIfHealthFactorIsBroken(msg.sender);
    }

    /**
     * @notice follows CEI
     * @param amountMscToMint The amount of Metana Stable coin to mint
     * @notice they must have more collateral value than MSC
     */
    function mintMsc(uint256 amountMscToMint) public moreThanZero(amountMscToMint) nonReentrant {
        s_MSCMinted[msg.sender] += amountMscToMint;
        _revertIfHealthFactorIsBroken(msg.sender);
        bool minted = i_msc.mint(msg.sender, amountMscToMint);
        if (!minted) revert MSCEngine__MintFailed();
    }

    function burnMsc(uint256 amount) public moreThanZero(amount) {
        _burnMsc(amount, msg.sender, msg.sender);
        _revertIfHealthFactorIsBroken(msg.sender);
    }

    /**
     *
     * @param collateral ERC20 collateral address to liquidate
     * @param user The user who has broken healthFactor -> _healthFactor < MIN_HEALTH_FACTOR
     * @param debtToCover The amount of MSC you want to burn to improve the users health factor
     * @notice You can partially liquidate a user.
     * @notice You will get a liquidation bonus to take the users funds.
     * @notice This function assumes the protocol will be roughly 200% overcollateralized.
     */
    function liquidate(address collateral, address user, uint256 debtToCover)
        external
        moreThanZero(debtToCover)
        nonReentrant
    {
        uint256 startingUserHealthFactor = _healthFactor(user);
        if (startingUserHealthFactor >= MIN_HEALTH_FACTOR) revert MSCEngine__HealthyHealthFactor();

        uint256 tokenAmountFromDebtCovered = getTokenAmountFromUsd(collateral, debtToCover);
        uint256 bonusCollateral = (tokenAmountFromDebtCovered * LIQUIDATION_BONUS) / LIQUIDATION_PRECISION;
        uint256 totalCollateralToRedeem = tokenAmountFromDebtCovered + bonusCollateral;

        _redeemCollateral(collateral, totalCollateralToRedeem, user, msg.sender);
        _burnMsc(debtToCover, user, msg.sender);

        uint256 endingUserHealthFactor = _healthFactor(user);
        if (endingUserHealthFactor <= startingUserHealthFactor) {
            revert MSCEngine__HealthFactorNotImproved();
        }
        _revertIfHealthFactorIsBroken(msg.sender);
    }

    //////////////////////////////////
    // Private & Internal Functions //
    /////////////////////////////////

    function _burnMsc(uint256 amountMscToBurn, address onBehalfOf, address mscFrom) private {
        s_MSCMinted[onBehalfOf] -= amountMscToBurn;
        bool success = i_msc.transferFrom(mscFrom, address(this), amountMscToBurn);
        if (!success) revert MSCEngine__TransferFailed();
        i_msc.burn(amountMscToBurn);
    }

    function _redeemCollateral(address tokenCollateralAddress, uint256 amountCollateral, address from, address to)
        private
    {
        s_collateralDeposited[from][tokenCollateralAddress] -= amountCollateral;
        emit CollateralReedeemed(from, to, tokenCollateralAddress, amountCollateral);
        bool success = IERC20(tokenCollateralAddress).transfer(to, amountCollateral);
        if (!success) revert MSCEngine__TransferFailed();
    }

    function _getAccountInformation(address user)
        private
        view
        returns (uint256 totalMscMinted, uint256 collateralValueInUsd)
    {
        totalMscMinted = s_MSCMinted[user];
        collateralValueInUsd = getAccountCollateralValue(user);
    }

    /**
     * Returns how close a user is to liquidation.
     * If user goes below 1 they can be liquidated.
     * @param user User you want to see health factor of.
     */
    function _healthFactor(address user) private view returns (uint256) {
        (uint256 totalMscMinted, uint256 collateralValueInUsd) = _getAccountInformation(user);
        return _calculateHealthFactor(totalMscMinted, collateralValueInUsd);
    }

    function _revertIfHealthFactorIsBroken(address user) internal view {
        uint256 userHealthFactor = _healthFactor(user);
        if (userHealthFactor < MIN_HEALTH_FACTOR) revert MSCEngine__BreaksHealthFactor(userHealthFactor);
    }

    function _calculateHealthFactor(uint256 totalMscMinted, uint256 collateralValueInUsd)
        internal
        pure
        returns (uint256)
    {
        if (totalMscMinted == 0) return type(uint256).max;
        uint256 collateralAdjustedForThreshold = (collateralValueInUsd * LIQUIDATION_THRESHOLD) / LIQUIDATION_PRECISION;
        return (collateralAdjustedForThreshold * DECIMAL_PRECISION) / totalMscMinted;
    }

    function _getAccountCollateralValue(address user) private view returns (uint256 totalCollateralValueInUsd) {
        for (uint256 i = 0; i < s_collateralTokens.length; i++) {
            address token = s_collateralTokens[i];
            uint256 amount = s_collateralDeposited[user][token];
            totalCollateralValueInUsd += getUsdValue(token, amount);
        }
    }

    //////////////////////////////////
    // Public & External Functions  //
    /////////////////////////////////

    function calculateHealthFactor(uint256 totalMscMinted, uint256 collateralValueInUsd)
        external
        pure
        returns (uint256)
    {
        return _calculateHealthFactor(totalMscMinted, collateralValueInUsd);
    }

    function getAccountInformation(address user)
        external
        view
        returns (uint256 totalMscMinted, uint256 collateralValueInUsd)
    {
        (totalMscMinted, collateralValueInUsd) = _getAccountInformation(user);
    }

    function getCollateralBalanceOfUser(address user, address token) external view returns (uint256) {
        return s_collateralDeposited[user][token];
    }

    function getUsdValue(address token, uint256 amount) public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(s_priceFeeds[token]);
        (, int256 price,,,) = priceFeed.latestRoundData();

        return ((uint256(price) * ADDITIONAL_FEED_PRECISION) * amount) / DECIMAL_PRECISION;
    }

    function getTokenAmountFromUsd(address token, uint256 usdAmountinWei) public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(s_priceFeeds[token]);
        (, int256 price,,,) = priceFeed.latestRoundData();
        return (usdAmountinWei * DECIMAL_PRECISION) / (uint256(price) * ADDITIONAL_FEED_PRECISION);
    }

    function getHealthFactor(address user) public view returns (uint256) {
        return _healthFactor(user);
    }

    function getAccountCollateralValue(address user) public view returns (uint256) {
        return _getAccountCollateralValue(user);
    }

    function getPrecision() external pure returns (uint256) {
        return DECIMAL_PRECISION;
    }

    function getAdditionalFeedPrecision() external pure returns (uint256) {
        return ADDITIONAL_FEED_PRECISION;
    }

    function getLiquidationThreshold() external pure returns (uint256) {
        return LIQUIDATION_THRESHOLD;
    }

    function getLiquidationBonus() external pure returns (uint256) {
        return LIQUIDATION_BONUS;
    }

    function getLiquidationPrecision() external pure returns (uint256) {
        return LIQUIDATION_PRECISION;
    }

    function getMinHealthFactor() external pure returns (uint256) {
        return MIN_HEALTH_FACTOR;
    }

    function getCollateralTokens() external view returns (address[] memory) {
        return s_collateralTokens;
    }

    function getCollateralTokenPriceFeed(address token) external view returns (address) {
        return s_priceFeeds[token];
    }

    function getMsc() external view returns (address) {
        return address(i_msc);
    }
}
