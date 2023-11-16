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
		merkleRoot = merkleTree.getRoot(); // Get the root as a Buffer

		const AdvancedNFT = await ethers.getContractFactory('AdvancedNFT');
		advancedNFT = await AdvancedNFT.deploy(
			'AdvancedNFT',
			'ANFT',
			'0x' + merkleRoot.toString('hex')
		);
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
});
