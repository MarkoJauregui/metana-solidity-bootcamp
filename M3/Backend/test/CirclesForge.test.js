const { expect } = require("chai");
const { ethers } = require("hardhat");

const MINTER_ROLE = ethers.utils.id("MINTER_ROLE"); // Or whatever your role's bytes32 representation is

describe("CirclesForge", function () {
  let circlesERC1155;
  let circlesForge;
  let owner;
  let user;

  beforeEach(async () => {
    [owner, user] = await ethers.getSigners();

    const CirclesERC1155 = await ethers.getContractFactory("CirclesERC1155");
    circlesERC1155 = await CirclesERC1155.deploy();
    await circlesERC1155.deployed();

    const CirclesForge = await ethers.getContractFactory("CirclesForge");
    circlesForge = await CirclesForge.deploy(circlesERC1155.address);
    await circlesForge.deployed();

    // Grant MINTER_ROLE to CirclesForge
    await circlesERC1155.grantRole(MINTER_ROLE, circlesForge.address);

    await circlesERC1155.mint(user.address, 0);
    await ethers.provider.send("evm_increaseTime", [60]); // Increase time by 60 seconds
    await ethers.provider.send("evm_mine"); // Mine a new block to reflect the time change

    await circlesERC1155.mint(user.address, 1);
    await ethers.provider.send("evm_increaseTime", [60]);
    await ethers.provider.send("evm_mine");

    await circlesERC1155.mint(user.address, 2);
    await ethers.provider.send("evm_increaseTime", [60]);
    await ethers.provider.send("evm_mine");

    // User approves CirclesForge to manage their tokens
    await circlesERC1155
      .connect(user)
      .setApprovalForAll(circlesForge.address, true);
  });

  it("Should forge Token 6 correctly", async () => {
    // Wait for cooldown (if any)

    // User forges the token
    await circlesForge.connect(user).forgeToken6();

    // Check user's new token balance
    expect(await circlesERC1155.balanceOf(user.address, 6)).to.equal(1);
  });
});
