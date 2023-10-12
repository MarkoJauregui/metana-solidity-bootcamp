const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('CirclesForge', function () {
	let CirclesERC1155, circlesERC1155;
	let CirclesForge, circlesForge;
	let owner, addr1, addr2;

	beforeEach(async function () {
		// Deploy CirclesERC1155 contract
		CirclesERC1155 = await ethers.getContractFactory('CirclesERC1155');
		[owner, addr1, addr2] = await ethers.getSigners();
		circlesERC1155 = await CirclesERC1155.deploy();

		// Deploy CirclesForge contract
		CirclesForge = await ethers.getContractFactory('CirclesForge');
		circlesForge = await CirclesForge.deploy(circlesERC1155.address);

		// Set the forging contract in the CirclesERC1155 contract
		await circlesERC1155.setForgingContract(circlesForge.address);
	});

	describe('Forging Tokens', function () {
		describe('ForgeToken3', () => {
			it('Should forge Token 3 by burning Token 0 and 1', async function () {
				// Mint tokens for the user
				await circlesERC1155.mint(addr1.address, 0, 10);
				await circlesERC1155.mint(addr1.address, 1, 10);

				// Forge Token 3
				await circlesForge.connect(addr1).forgeToken3(5);

				// Check resulting balances
				expect(await circlesERC1155.balanceOf(addr1.address, 0)).to.equal(5);
				expect(await circlesERC1155.balanceOf(addr1.address, 1)).to.equal(5);
				expect(await circlesERC1155.balanceOf(addr1.address, 3)).to.equal(5);
			});
			it('Should revert if trying to forge Token 3 with insufficient Token 0 balance', async function () {
				await circlesERC1155.mint(owner.address, 1, 5); // Mint some of Token 1 for balance
				await expect(
					circlesForge.connect(owner).forgeToken3(5)
				).to.be.revertedWith('CirclesForge__InsufficientToken0');
			});

			it('Should revert if trying to forge Token 3 with insufficient Token 1 balance', async function () {
				await circlesERC1155.mint(owner.address, 0, 5); // Mint some of Token 0 for balance
				await expect(
					circlesForge.connect(owner).forgeToken3(5)
				).to.be.revertedWith('CirclesForge__InsufficientToken1');
			});
		});

		describe('ForgeToken4', () => {
			it('Should forge Token 4 by burning Token 1 and 2', async function () {
				// Mint tokens for the user
				await circlesERC1155.mint(addr1.address, 1, 10);
				await circlesERC1155.mint(addr1.address, 2, 10);

				// Forge Token 4
				await circlesForge.connect(addr1).forgeToken4(5);

				// Check resulting balances
				expect(await circlesERC1155.balanceOf(addr1.address, 1)).to.equal(5);
				expect(await circlesERC1155.balanceOf(addr1.address, 2)).to.equal(5);
				expect(await circlesERC1155.balanceOf(addr1.address, 4)).to.equal(5);
			});

			it('Should revert if trying to forge Token 4 with insufficient Token 1 balance', async function () {
				await circlesERC1155.mint(owner.address, 2, 5); // Mint some of Token 1 for balance
				await expect(
					circlesForge.connect(owner).forgeToken4(5)
				).to.be.revertedWith('CirclesForge__InsufficientToken1');
			});

			it('Should revert if trying to forge Token 4 with insufficient Token 1 balance', async function () {
				await circlesERC1155.mint(owner.address, 1, 5); // Mint some of Token 0 for balance
				await expect(
					circlesForge.connect(owner).forgeToken4(5)
				).to.be.revertedWith('CirclesForge__InsufficientToken2');
			});
		});

		describe('forgeToken5', () => {
			it('Should forge Token 5 by burning Token 0 and 2', async function () {
				// Mint tokens for the user
				await circlesERC1155.mint(addr1.address, 0, 10);
				await circlesERC1155.mint(addr1.address, 2, 10);

				// Forge Token 5
				await circlesForge.connect(addr1).forgeToken5(5);

				// Check resulting balances
				expect(await circlesERC1155.balanceOf(addr1.address, 0)).to.equal(5);
				expect(await circlesERC1155.balanceOf(addr1.address, 2)).to.equal(5);
				expect(await circlesERC1155.balanceOf(addr1.address, 5)).to.equal(5);
			});
			it('Should revert if trying to forge Token 5 with insufficient Token 0 balance', async function () {
				await circlesERC1155.mint(owner.address, 2, 5); // Mint some of Token 1 for balance
				await expect(
					circlesForge.connect(owner).forgeToken5(5)
				).to.be.revertedWith('CirclesForge__InsufficientToken0');
			});

			it('Should revert if trying to forge Token 5 with insufficient Token 2 balance', async function () {
				await circlesERC1155.mint(owner.address, 0, 5); // Mint some of Token 0 for balance
				await expect(
					circlesForge.connect(owner).forgeToken5(5)
				).to.be.revertedWith('CirclesForge__InsufficientToken2');
			});
		});

		describe('forgeToken6', () => {
			it('Should forge Token 6 by burning Token 0 and 1', async function () {
				// Mint tokens for the user
				await circlesERC1155.mint(addr1.address, 0, 10);
				await circlesERC1155.mint(addr1.address, 1, 10);
				await circlesERC1155.mint(addr1.address, 2, 10);

				// Forge Token 3
				await circlesForge.connect(addr1).forgeToken6(5);

				// Check resulting balances
				expect(await circlesERC1155.balanceOf(addr1.address, 0)).to.equal(5);
				expect(await circlesERC1155.balanceOf(addr1.address, 1)).to.equal(5);
				expect(await circlesERC1155.balanceOf(addr1.address, 2)).to.equal(5);
				expect(await circlesERC1155.balanceOf(addr1.address, 6)).to.equal(5);
			});

			it('Should revert if trying to forge Token 6 with insufficient Token 0 balance', async function () {
				await circlesERC1155.mint(owner.address, 1, 5);
				await circlesERC1155.mint(owner.address, 2, 5);
				await expect(
					circlesForge.connect(owner).forgeToken6(5)
				).to.be.revertedWith('CirclesForge__InsufficientToken0');
			});

			it('Should revert if trying to forge Token 6 with insufficient Token 1 balance', async function () {
				await circlesERC1155.mint(owner.address, 0, 5);
				await circlesERC1155.mint(owner.address, 2, 5);
				await expect(
					circlesForge.connect(owner).forgeToken6(5)
				).to.be.revertedWith('CirclesForge__InsufficientToken1');
			});

			it('Should revert if trying to forge Token 6 with insufficient Token 1 balance', async function () {
				await circlesERC1155.mint(owner.address, 0, 5);
				await circlesERC1155.mint(owner.address, 1, 5);
				await expect(
					circlesForge.connect(owner).forgeToken6(5)
				).to.be.revertedWith('CirclesForge__InsufficientToken2');
			});
		});
	});
});
