# MetanaStableCoin Project Documentation

## Overview

The MetanaStableCoin project consists of two main smart contracts: `MetanaStableCoin.sol` and `MSCEngine.sol`. This system is designed to maintain a stablecoin, Metana Stable Coin (MSC), pegged 1:1 with the US dollar. Inspired by MakerDAO's DAI system, it operates without governance and fees, ensuring always-overcollateralized positions with wETH & wBTC.

### Contracts

#### MetanaStableCoin.sol

##### Description

`MetanaStableCoin` is an ERC20 token with burnable capabilities, extending OpenZeppelin's `ERC20Burnable` and `Ownable` contracts. It represents the stablecoin within the ecosystem, with its value intended to be pegged to the US dollar.

##### Key Functions

- **constructor**: Initializes the token with a name and symbol and sets the contract deployer as the owner.
- **burn**: Allows the owner to burn (destroy) a specific amount of tokens from their balance, reducing the total supply.
- **mint**: Enables the owner to create new tokens, increasing the total supply. This function is restricted to the contract owner to control the supply according to the collateralized assets within the MSCEngine.

#### MSCEngine.sol

##### Description

`MSCEngine` is the core contract managing the logic for minting, redeeming, depositing, and withdrawing collateral against MSC tokens. It utilizes price feeds from Chainlink to ensure the system remains overcollateralized, following a model similar to MakerDAO's DAI but simplified and without governance.

##### Key Features

- **Collateral Management**: Users can deposit selected ERC20 tokens as collateral to mint MSC. The contract supports multiple collateral types, each associated with a Chainlink price feed for real-time valuation.
- **Minting and Burning**: Users mint MSC by locking in collateral exceeding the value of MSC minted, ensuring overcollateralization. Users can burn MSC to withdraw their collateral, maintaining the peg and system health.
- **Liquidation**: If a user's collateral value falls below a certain health factor, part of their collateral can be liquidated to cover the debt, ensuring the system's stability.
- **Health Factor**: A critical measure of account safety, ensuring that each account maintains sufficient collateral relative to their minted MSC. It prevents undercollateralized positions and potential system insolvency.

##### Functions Overview

- **depositCollateralAndMintMsc**: Combines collateral deposit and MSC minting in a single transaction.
- **depositCollateral**: Allows users to deposit approved ERC20 tokens as collateral.
- **reedemCollateralForMsc**: Enables users to redeem their collateral by burning MSC.
- **mintMsc**: Mints MSC against the user's collateral, ensuring the health factor is maintained.
- **burnMsc**: Burns MSC, allowing users to manage their debt and potentially withdraw collateral.
- **liquidate**: Allows liquidators to improve an undercollateralized account's health factor by burning MSC in exchange for collateral at a bonus, ensuring the system's stability.

### Security Features

- **ReentrancyGuard**: Protects against reentrancy attacks, ensuring that functions cannot be re-entered while they're still executing.
- **Chainlink Price Feeds**: Provides reliable and tamper-proof price data for collateral valuation.
- **Custom Errors**: Improves gas efficiency and error readability compared to traditional `require` statements.
- **Non-Custodial**: Users retain control over their collateral until specific conditions are met for withdrawal or liquidation.

### Conclusion

The MetanaStableCoin project introduces a simplified, governance-free stablecoin system. By leveraging overcollateralization and real-time price feeds, it aims to maintain a stable value for MSC, facilitating its use as a medium of exchange and store of value. The system's design prioritizes security, transparency, and user autonomy, contributing to the broader ecosystem of decentralized finance (DeFi).
