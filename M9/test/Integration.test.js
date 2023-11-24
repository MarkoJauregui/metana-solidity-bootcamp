const { expect } = require('chai');
const { ethers, upgrades } = require('hardhat');

describe('Integration Tests', function () {
	let circlesNFT, erc20Test, nftStaking;
	let deployer, user1, user2;
	const NFT_PRICE = ethers.utils.parseEther('0.01');

	beforeEach(async function () {
		[deployer, user1, user2] = await ethers.getSigners();

		// Deploy CirclesNFT
		const CirclesNFT = await ethers.getContractFactory('CirclesNFT');
		circlesNFT = await upgrades.deployProxy(CirclesNFT, [], {
			initializer: 'initialize',
		});
		await circlesNFT.deployed();

		// Deploy ERC20Test
		const ERC20Test = await ethers.getContractFactory('ERC20Test');
		erc20Test = await upgrades.deployProxy(ERC20Test, [], {
			initializer: 'initialize',
		});
		await erc20Test.deployed();

		// Deploy NFTStaking
		const NFTStaking = await ethers.getContractFactory('NFTStaking');
		nftStaking = await upgrades.deployProxy(
			NFTStaking,
			[erc20Test.address, circlesNFT.address],
			{ initializer: 'initialize' }
		);
		await nftStaking.deployed();

		// Set staking contract address in CirclesNFT
		await circlesNFT.setStakingContract(nftStaking.address);
		await erc20Test.transfer(
			nftStaking.address,
			ethers.utils.parseEther('100')
		);
	});

	describe('CirclesNFT', function () {
		it('Should mint an NFT', async function () {
			await expect(
				circlesNFT.connect(user1).mint({ value: NFT_PRICE })
			).to.emit(circlesNFT, 'Transfer');
			expect(await circlesNFT.balanceOf(user1.address)).to.equal(1);
		});
	});

	describe('ERC20Test', function () {
		it('Deployer should have initial tokens', async function () {
			expect(await erc20Test.balanceOf(deployer.address)).to.be.gt(0);
		});
	});
	describe('NFTStaking', function () {
		it('Should allow staking and reward withdrawal', async function () {
			// User1 mints an NFT
			await circlesNFT.connect(user1).mint({ value: NFT_PRICE });
			const tokenId = 0;

			// User1 approves NFTStaking contract to transfer their NFT
			await circlesNFT.connect(user1).approve(nftStaking.address, tokenId);

			// User1 stakes the NFT
			await nftStaking.connect(user1).stakeNFT(tokenId);

			// Simulate time passing and withdraw ERC20 rewards
			await ethers.provider.send('evm_increaseTime', [24 * 60 * 60]); // Increase time by 1 day
			await nftStaking.connect(user1).withdrawERC20(tokenId);
			expect(await erc20Test.balanceOf(user1.address)).to.be.gt(0);

			// Unstake NFT
			await nftStaking.connect(user1).unstakeNFT(tokenId);

			// Check ownership after unstaking
			const ownerAfterUnstaking = await circlesNFT.ownerOf(tokenId);
			console.log('Owner of tokenId after unstaking:', ownerAfterUnstaking);

			expect(ownerAfterUnstaking).to.equal(user1.address);
		});
	});
});
