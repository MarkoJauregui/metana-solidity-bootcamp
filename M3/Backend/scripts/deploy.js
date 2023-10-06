const { ethers } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);
  console.log("Account balance:", (await deployer.getBalance()).toString());

  // Deploy CirclesERC1155 contract
  const CirclesERC1155 = await ethers.getContractFactory("CirclesERC1155");
  const circlesERC1155 = await CirclesERC1155.deploy(
    "ipfs://QmdpEYwJircF4qH5imJG4bJT3TH6rNYxzCL2d8B4bG7Uhy/{id}"
  );
  await circlesERC1155.deployed();

  console.log("CirclesERC1155 contract deployed to:", circlesERC1155.address);

  // Deploy CirclesForge contract with the address of CirclesERC1155
  const CirclesForge = await ethers.getContractFactory("CirclesForge");
  const circlesForge = await CirclesForge.deploy(circlesERC1155.address);
  await circlesForge.deployed();

  console.log("CirclesForge contract deployed to:", circlesForge.address);

  // Set CirclesForge as the forging contract in CirclesERC1155
  await circlesERC1155.setForgingContract(circlesForge.address);
  console.log("Set CirclesForge as the forging contract in CirclesERC1155");

  // Grant minting rights to CirclesForge contract
  await circlesERC1155.grantRole(
    circlesERC1155.MINTER_ROLE(),
    circlesForge.address
  );
  console.log("Granted minting rights to CirclesForge contract");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
