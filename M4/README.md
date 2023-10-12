# M4 Repository

This repository contains Solidity smart contracts, including:

### CirclesERC1155.sol

A custom ERC1155 token implementation.

### CirclesForge.sol

A contract to interact with CirclesERC1155.sol for forging logic.

### PartialRefund.sol

A modified version of the TokenSale contract, where users can mint and sell back tokens.

### Prerequisites

Ensure you have Node.js and npm installed.

### Installation

1. Clone the repository

```bash
git clone https://github.com/MarkoJauregui/metana-solidity-bootcamp.git
```

### Navigate to the repository folder:

```bash
cd M4
```

#### Install the dependencies:

```bash
npm install
```

#### Running Tests

To run the tests, use the following command:

```bash
npx hardhat test
```

### Checking Coverage

To check the code coverage, use the following command:

```bash
npx hardhat coverage
```
