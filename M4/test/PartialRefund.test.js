const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('PartialRefund', function () {
	let PartialRefund, partialRefund, owner, addr1, addr2;

	beforeEach(async function () {
		PartialRefund = await ethers.getContractFactory('PartialRefund');
		[owner, addr1, addr2] = await ethers.getSigners();
		partialRefund = await PartialRefund.deploy('TestToken', 'TST');
	});

	describe('Deployment', function () {
		it('Should deploy the contract', async function () {
			expect(partialRefund.address).to.exist;
		});

		it('Should set the right owner', async function () {
			expect(await partialRefund.owner()).to.equal(owner.address);
		});

		it('Should assign the initial supply of tokens to the owner', async function () {
			const ownerBalance = await partialRefund.balanceOf(owner.address);
			expect(ownerBalance).to.equal(ethers.utils.parseEther('10000'));
		});

		it('Should have correct token name and symbol', async function () {
			expect(await partialRefund.name()).to.equal('TestToken');
			expect(await partialRefund.symbol()).to.equal('TST');
		});
	});

	describe('Minting Tokens', function () {
		it('Should mint 1000 tokens for 1 Ether', async function () {
			// Mint tokens by sending 1 Ether
			await partialRefund
				.connect(owner)
				.mintTokens({ value: ethers.utils.parseEther('1') });

			const balance = await partialRefund.balanceOf(owner.address);
			expect(balance).to.equal(ethers.utils.parseEther('11000')); // 10,000 initial + 1,000 from minting
		});

		it('Should not allow minting with less than 1 Ether', async function () {
			// Try to mint tokens with less than 1 Ether
			await expect(
				partialRefund
					.connect(addr1)
					.mintTokens({ value: ethers.utils.parseEther('0.5') })
			).to.be.revertedWith('PartialRefund__IncorrectMintingPrice');
		});

		it('should not allow minting tokens that exceed MAX_SUPPLY', async function () {
			// Minting almost to the max supply, leaving only 10 tokens space
			await partialRefund.adminMint(
				owner.address,
				ethers.utils.parseEther('989990')
			);

			const newBalance = await partialRefund.balanceOf(owner.address);
			expect(newBalance).to.equal(ethers.utils.parseEther('999990')); // Check the balance is 999,990

			// Mint 10 more tokens to reach MAX_SUPPLY
			await partialRefund
				.connect(owner)
				.mintTokens({ value: ethers.utils.parseEther('1') });

			const finalBalance = await partialRefund.balanceOf(owner.address);
			expect(finalBalance).to.equal(ethers.utils.parseEther('1000000')); // Check the balance is 1,000,000

			// Try to mint more tokens again, which should be rejected
			await expect(
				partialRefund
					.connect(owner)
					.mintTokens({ value: ethers.utils.parseEther('1') })
			).to.be.revertedWith('PartialRefund__SaleHasEnded');
		});
	});

	describe('Selling Back Tokens', function () {
		it('Should allow selling back tokens for Ether', async function () {
			// Initial balance of address 2
			console.log(
				'Initial Address 2 Balance:',
				ethers.utils.formatEther(await addr2.getBalance())
			);

			// Mint tokens for addr1 (this will add 1 Ether to the contract)
			await partialRefund
				.connect(addr1)
				.mintTokens({ value: ethers.utils.parseEther('1') });

			// Mint tokens for addr2 (this will add another Ether, making it 2 Ether in total in the contract)
			console.log(
				'Balance before minting:',
				ethers.utils.formatEther(await addr2.getBalance())
			);
			await partialRefund
				.connect(addr2)
				.mintTokens({ value: ethers.utils.parseEther('1') });
			console.log(
				'Balance after minting:',
				ethers.utils.formatEther(await addr2.getBalance())
			);

			// Calculate the ether to be paid as per contract logic
			const etherToPay = ethers.utils.parseEther('0.5'); // This is fixed at 0.5 ETH for 1000 tokens
			console.log('etherToPay:', ethers.utils.formatUnits(etherToPay, 'ether'));

			// Contract balance before sellBack
			const contractBalanceBefore = await ethers.provider.getBalance(
				partialRefund.address
			);
			console.log(
				'contractBalance:',
				ethers.utils.formatUnits(contractBalanceBefore, 'ether')
			);

			// Now, sell back the tokens
			await partialRefund
				.connect(addr2)
				.sellBack(ethers.utils.parseEther('1000'));
			console.log(
				'Balance after sellBack:',
				ethers.utils.formatEther(await addr2.getBalance())
			);

			// Check final balance of addr2
			const finalBalance = await addr2.getBalance();
			expect(finalBalance).to.be.gt(etherToPay);
		});

		it('Should not allow selling back more tokens than user has', async function () {
			await expect(
				partialRefund.connect(addr1).sellBack(ethers.utils.parseEther('1000'))
			).to.be.reverted; // addr1 has no tokens yet
		});

		it('Should not allow selling back tokens if contract does not have enough Ether', async function () {
			await partialRefund
				.connect(addr1)
				.mintTokens({ value: ethers.utils.parseEther('1') });

			// Draining contract's Ether
			await partialRefund.connect(owner).withdraw();

			await expect(
				partialRefund.connect(addr1).sellBack(ethers.utils.parseEther('1000'))
			).to.be.revertedWith('PartialRefund__InsufficientEtherBalance');
		});

		it('Check token and Ether balances after selling back', async function () {
			await partialRefund
				.connect(addr1)
				.mintTokens({ value: ethers.utils.parseEther('1') });

			const initialTokenBalance = await partialRefund.balanceOf(addr1.address);
			const initialEtherBalance = await addr1.getBalance();

			await partialRefund
				.connect(addr1)
				.sellBack(ethers.utils.parseEther('500'));

			const finalTokenBalance = await partialRefund.balanceOf(addr1.address);
			const finalEtherBalance = await addr1.getBalance();

			expect(initialTokenBalance.sub(finalTokenBalance)).to.equal(
				ethers.utils.parseEther('500')
			);
			expect(finalEtherBalance.sub(initialEtherBalance)).to.be.closeTo(
				ethers.utils.parseEther('0.25'),
				ethers.utils.parseEther('0.01')
			); // accounting for gas costs
		});
	});

	describe('Error Handling', function () {
		it('Should revert if minting would exceed MAX_SUPPLY', async function () {
			// Step 1: Set the token supply just a bit less than MAX_SUPPLY, the initial supply is 10k
			const initialSupply = await partialRefund.totalSupply();
			const remainingSupply = (await partialRefund.getMaxSupply()).sub(
				initialSupply
			); // 100 tokens left
			await partialRefund.adminMint(owner.address, remainingSupply);

			// Log the totalSupply before the minting attempt
			const totalSupplyBeforeMint = await partialRefund.totalSupply();

			await expect(
				partialRefund
					.connect(addr1)
					.mintTokens({ value: ethers.utils.parseEther('1') })
			).to.be.revertedWith('PartialRefund__SaleHasEnded');
		});

		it('Should revert if incorrect minting price is sent', async function () {
			await expect(
				partialRefund.connect(addr1).mintTokens({ value: '5' })
			).to.be.revertedWith('PartialRefund__IncorrectMintingPrice');
		});
	});

	describe('Getter Functions', function () {
		it('Checks getMaxSupply works', async function () {
			const maxSupply = await partialRefund.getMaxSupply();
			expect(maxSupply.toString()).to.eq('1000000000000000000000000');
		});

		it('Checks TokensPerEth works', async function () {
			const tokensPerEth = await partialRefund.getTokensPerEther();
			expect(tokensPerEth).to.eq('1000000000000000000000');
		});
	});

	describe('Receive/Fallback Functions', function () {
		it('Should mint tokens when Ether is sent to the contract address', async function () {
			const initialBalance = await partialRefund.balanceOf(addr1.address);

			// Send 1 Ether to the contract address
			await addr1.sendTransaction({
				to: partialRefund.address,
				value: ethers.utils.parseEther('1'),
			});

			// Check if addr1's token balance increased by the expected amount
			const finalBalance = await partialRefund.balanceOf(addr1.address);
			expect(finalBalance.toString()).to.equal(
				initialBalance.add('1000000000000000000000')
			); // Assuming 1000 tokens per Ether
		});
	});
});
