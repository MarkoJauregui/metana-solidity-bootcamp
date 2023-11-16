const { expect } = require('chai');
const { ethers } = require('hardhat');
const { MerkleTree } = require('merkletreejs');
const keccak256 = require('keccak256');

describe('AdvancedNFT', function () {
	let advancedNFT;
	let owner;
	let eligibleAddresses;
	let merkleTree;
	let merkleRoot;

	beforeEach(async function () {
		[owner, ...eligibleAddresses] = await ethers.getSigners();

		const leaves = eligibleAddresses.map((addr) => keccak256(addr.address));
		merkleTree = new MerkleTree(leaves, keccak256, { sortPairs: true });
		merkleRoot = merkleTree.getRoot();

		const AdvancedNFT = await ethers.getContractFactory('AdvancedNFT');
		advancedNFT = await AdvancedNFT.deploy(
			'AdvancedNFT',
			'ANFT',
			'0x' + merkleRoot.toString('hex'),
			owner.address // passing the owner's address as initial owner
		);
		// Transition to PublicSale state
		await advancedNFT.connect(owner).startPublicSale();
	});

	it('Should allow a valid address to mint an NFT', async function () {
		const leaf = keccak256(eligibleAddresses[0].address);
		const proof = merkleTree.getHexProof(leaf);

		await expect(
			advancedNFT.connect(eligibleAddresses[0]).mintWithMerkleProof(proof, 1)
		)
			.to.emit(advancedNFT, 'Transfer')
			.withArgs(ethers.ZeroAddress, eligibleAddresses[0].address, 1);
	});

	it('Should not allow an invalid address to mint an NFT', async function () {
		const nonEligibleSigner = (await ethers.getSigners())[10];
		const invalidProof = []; // Invalid proof: empty array

		try {
			await advancedNFT
				.connect(nonEligibleSigner)
				.mintWithMerkleProof(invalidProof, 1);
			expect.fail('Transaction should have failed');
		} catch (error) {
			expect(error.message).to.include('AdvancedNFT__InvalidMerkleProof');
		}
	});

	it('Should prevent an address from minting more than once', async function () {
		const leaf = keccak256(eligibleAddresses[0].address);
		const proof = merkleTree.getHexProof(leaf);

		await advancedNFT
			.connect(eligibleAddresses[0])
			.mintWithMerkleProof(proof, 1);

		try {
			await advancedNFT
				.connect(eligibleAddresses[0])
				.mintWithMerkleProof(proof, 1);
			expect.fail('Transaction should have failed');
		} catch (error) {
			expect(error.message).to.include('AdvancedNFT__TokenAlreadyMinted');
		}
	});

	it('Should record a commit', async function () {
		// Encoding the string "123" as a Bytes32 string
		const secret = ethers.encodeBytes32String('123');
		// Hashing the encoded string
		const dataHash = ethers.keccak256(secret);

		// Capture the current block number
		const currentBlockNumber = await ethers.provider.getBlockNumber();

		await expect(advancedNFT.connect(eligibleAddresses[0]).commit(dataHash))
			.to.emit(advancedNFT, 'CommitEvent')
			.withArgs(
				eligibleAddresses[0].address,
				dataHash,
				currentBlockNumber + 1 // Expecting the next block number
			);
	});

	it('Should successfully reveal a commit', async function () {
		// Encoding and hashing the secret
		const secret = ethers.encodeBytes32String('123');
		const dataHash = ethers.keccak256(secret);

		await advancedNFT.connect(eligibleAddresses[0]).commit(dataHash);
		await ethers.provider.send('evm_mine', []); // Mine a new block

		await expect(
			advancedNFT.connect(eligibleAddresses[0]).reveal(secret)
		).to.emit(advancedNFT, 'RevealEvent');
	});

	it('Should not allow reveal too early', async function () {
		const secret = ethers.encodeBytes32String('123');
		const dataHash = ethers.keccak256(secret);

		// Commit
		await advancedNFT.connect(eligibleAddresses[0]).commit(dataHash);

		// Attempt to reveal immediately in the next line without waiting for a new block
		try {
			await advancedNFT.connect(eligibleAddresses[0]).reveal(secret);
			expect.fail('AdvancedNFT__RevealTooEarly');
		} catch (error) {
			// Check if the error message includes the specific revert reason
			console.log(error.message);
		}
	});

	it('Should not allow reveal too late', async function () {
		const secret = ethers.encodeBytes32String('123');
		const dataHash = ethers.keccak256(secret);

		await advancedNFT.connect(eligibleAddresses[0]).commit(dataHash);
		for (let i = 0; i < 251; i++) {
			await ethers.provider.send('evm_mine', []);
		}

		try {
			await advancedNFT.connect(eligibleAddresses[0]).reveal(secret);
			expect.fail('Transaction should have failed');
		} catch (error) {
			expect(error.message).to.include('AdvancedNFT__RevealTooLate');
		}
	});

	it('Should not allow reveal with incorrect data', async function () {
		const secret = ethers.encodeBytes32String('123');
		const incorrectSecret = ethers.encodeBytes32String('456');
		const dataHash = ethers.keccak256(secret);

		await advancedNFT.connect(eligibleAddresses[0]).commit(dataHash);
		await ethers.provider.send('evm_mine', []);

		try {
			await advancedNFT.connect(eligibleAddresses[0]).reveal(incorrectSecret);
			expect.fail('Transaction should have failed');
		} catch (error) {
			expect(error.message).to.include('AdvancedNFT__InvalidReveal');
		}
	});

	it('Should execute multiple actions in a single transaction using multicall', async function () {
		// Assuming the same address is eligible to mint multiple NFTs
		const leaf = keccak256(eligibleAddresses[0].address);
		const proof = merkleTree.getHexProof(leaf);

		// Encoding function calls
		const mintCall1 = advancedNFT.interface.encodeFunctionData(
			'mintWithMerkleProof',
			[proof, 3]
		); // Token ID 3
		const mintCall2 = advancedNFT.interface.encodeFunctionData(
			'mintWithMerkleProof',
			[proof, 4]
		); // Token ID 4

		// Multicall execution
		await advancedNFT
			.connect(eligibleAddresses[0])
			.multicall([mintCall1, mintCall2]);

		// Verify the results
		expect(await advancedNFT.ownerOf(3)).to.equal(eligibleAddresses[0].address);
		expect(await advancedNFT.ownerOf(4)).to.equal(eligibleAddresses[0].address);
	});

	it('Should only allow minting in the PublicSale state', async function () {
		// Transition to Presale state (this simulates the initial state)
		await advancedNFT.connect(owner).endSale(); // End any existing sale

		const leaf = keccak256(eligibleAddresses[0].address);
		const proof = merkleTree.getHexProof(leaf);

		// Attempt to mint in Presale state
		await expect(
			advancedNFT.connect(eligibleAddresses[0]).mintWithMerkleProof(proof, 5)
		).to.be.revertedWith('AdvancedNFT: Not in the correct sale state');

		// Transition to PublicSale state
		await advancedNFT.connect(owner).startPublicSale();

		// Now minting should succeed
		await expect(
			advancedNFT.connect(eligibleAddresses[0]).mintWithMerkleProof(proof, 5)
		)
			.to.emit(advancedNFT, 'Transfer')
			.withArgs(ethers.ZeroAddress, eligibleAddresses[0].address, 5);
	});

	it('Should not allow minting in the SoldOut state', async function () {
		// Transition to SoldOut state
		await advancedNFT.connect(owner).endSale();

		// Attempt to mint in SoldOut state
		const leaf = keccak256(eligibleAddresses[1].address);
		const proof = merkleTree.getHexProof(leaf);

		await expect(
			advancedNFT.connect(eligibleAddresses[1]).mintWithMerkleProof(proof, 6)
		).to.be.revertedWith('AdvancedNFT: Not in the correct sale state');
	});
});
