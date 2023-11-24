const { ethers, upgrades } = require('hardhat');

async function main() {
	const proxyAddress = '0xD9DD92e79aFE93127f720C957562E32E922f0261'; // The proxy address of CirclesNFT

	console.log('Upgrading CirclesNFT at proxy:', proxyAddress);

	// Deploy the new CirclesNFTV2 contract logic
	const CirclesNFTV2 = await ethers.getContractFactory('CirclesNFTV2');
	const upgraded = await upgrades.upgradeProxy(proxyAddress, CirclesNFTV2);

	console.log('CirclesNFT has been upgraded to:', upgraded.address);
}

main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error);
		process.exit(1);
	});
