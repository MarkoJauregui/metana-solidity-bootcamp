const { ethers, upgrades } = require('hardhat');

async function main() {
	const [deployer] = await ethers.getSigners();

	console.log('Deploying contracts with the account:', deployer.address);

	// Deploy CirclesNFT
	const CirclesNFT = await ethers.getContractFactory('CirclesNFT');
	const circlesNFT = await upgrades.deployProxy(CirclesNFT, [], {
		initializer: 'initialize',
	});
	await circlesNFT.deployed();
	console.log('CirclesNFT deployed to:', circlesNFT.address);

	// Deploy ERC20Test
	const ERC20Test = await ethers.getContractFactory('ERC20Test');
	const erc20Test = await upgrades.deployProxy(ERC20Test, [], {
		initializer: 'initialize',
	});
	await erc20Test.deployed();
	console.log('ERC20Test deployed to:', erc20Test.address);

	// Deploy NFTStaking
	const NFTStaking = await ethers.getContractFactory('NFTStaking');
	const nftStaking = await upgrades.deployProxy(
		NFTStaking,
		[erc20Test.address, circlesNFT.address],
		{ initializer: 'initialize' }
	);
	await nftStaking.deployed();
	console.log('NFTStaking deployed to:', nftStaking.address);
}

main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error);
		process.exit(1);
	});
