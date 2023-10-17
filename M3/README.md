# Circles Project

A blockchain-based project that allows users to mint, forge, and trade tokens. This repository contains both the smart contracts (backend) and the React front-end application.

## Prerequisites

- Node.js and npm
- [Metamask](https://metamask.io/download.html) extension installed on your browser
- Hardhat (`npm install --global hardhat`)

## Setup

### Backend

1. Navigate to the `Backend` directory:

   ```
   cd Backend
   ```

2. Install the required dependencies:

   ```
   npm install
   ```

3. Copy the `.env.example` file to a new file named `.env` and update the necessary variables.

4. Compile the smart contracts:

   ```
   npx hardhat compile
   ```

5. Deploy the smart contracts to the Hardhat local network:
   ```
   npx hardhat run scripts/deploy.js --network localhost
   ```

### Frontend

1. Navigate to the `Frontend/circles-app` directory:

   ```
   cd Frontend/circles-app
   ```

2. Install the required dependencies:

   ```
   npm install
   ```

3. Copy the `.env.example` file to a new file named `.env` and update the REACT_APP_INFURA_URL with your Infura URL as well as your private key and optionally your Polyscan API key for contract verification.

4. Ensure that the contract addresses in `contractConfig` are set to your deployed contracts or you can use the provided addresses that are already deployed on the Mumbai testnet in the following addresses: [CirclesERC1155](https://mumbai.polygonscan.com/address/0xE4900D0702c651d0050866A5f8d99DC6f6FE3bD9#code) & [CirclesForge](https://mumbai.polygonscan.com/address/0x463e5752d320B9dE669985cFE61593ca1Ba2Bc4c#code).

5. Start the React app:
   ```
   npm start
   ```

This should launch the application on `http://localhost:3000`.

### Connecting to the Blockchain

1. Open your browser and click on the Metamask extension.

2. Connect Metamask to the Hardhat local network or the Mumbai testnet.

3. Import an account using a private key or create a new one.

4. Once connected, navigate to `http://localhost:3000` and interact with the app.
