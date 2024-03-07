# Metana Stable Coin Project

This project consists of two main parts: the smart contract development environment set up with Foundry for the Metana Stable Coin (MSC) and its ecosystem, and a Next.js frontend application that interacts with the deployed contracts on the Sepolia testnet.

## Capstone (Smart Contracts)

Located in the `Capstone` directory, this part of the project includes the Solidity smart contracts for MSC, deployment scripts, and test scripts using Foundry.

### Prerequisites

- Foundry installed on your machine.
- Node.js and npm for running the frontend.

### Getting Started

1. **Install Foundry**

   Follow the instructions on the Foundry GitHub page to install Foundry and set up your environment.

2. **Compile Contracts**

   Navigate to the `Capstone` directory and run:

```
forge build
```

3. **Run Tests**

To execute the test suite, run:

```
forge test
```


4. **Deploy Contracts**

Adjust the deployment scripts as necessary for your environment and run:

```
forge script script/Deploy.s.sol:DeployScript --rpc-url YOUR_RPC_URL --private-key YOUR_PRIVATE_KEY --broadcast
```


Replace `YOUR_RPC_URL` with your Ethereum node RPC URL and `YOUR_PRIVATE_KEY` with your private key.

### Smart Contracts

- **MSCEngine.sol**: Core contract for minting, redeeming, and managing collateral.
- **MetanaStableCoin.sol**: ERC-20 token contract for MSC.
- **WETH.sol**: Wrapped ETH contract used as collateral.

## Frontend/msc-frontend (Next.js Application)

The frontend application allows users to interact with the MSC ecosystem through a web interface.

### Setup

1. Navigate to the `Frontend/msc-frontend` directory.
2. Install dependencies:

```
npm install
```


3. Run the development server:
```
npm run dev
```


Visit `http://localhost:3000` to view the application.

### Features

- **Connect Wallet**: Users can connect their Ethereum wallet.
- **Deposit Collateral and Mint MSC**: Users can deposit WETH as collateral and mint MSC tokens.
- **Redeem Collateral**: Users can redeem their collateral by burning MSC tokens.
- **View Health Factor**: Users can check the health factor of any account to assess liquidation risk.
- **Liquidate**: Users can liquidate accounts with a health factor below 1.

### Technologies Used

- **Solidity**: For smart contracts.
- **Foundry**: For testing and deploying smart contracts.
- **Next.js**: For the frontend application.
- **Ethers.js**: For interacting with Ethereum blockchain.
- **Tailwind CSS**: For styling the frontend application.

## Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues to suggest improvements or add new features.

## License

This project is licensed under the MIT License - see the LICENSE file for details.


