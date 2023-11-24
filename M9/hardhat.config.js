require('@nomiclabs/hardhat-ethers');
require('@nomiclabs/hardhat-waffle');
require('@openzeppelin/hardhat-upgrades');
require('@nomiclabs/hardhat-etherscan');

const SEPOLIA_RPC_URL = 'YOUR_SEPOLIA_RPC_URL'; // Replace with your Sepolia RPC URL
const PRIVATE_KEY = 'YOUR_PRIVATE_KEY'; // Replace with your private key
const ETHERSCAN_API_KEY = 'YOUR_ETHERSCAN_API_KEY'; // Replace with your Etherscan API key

module.exports = {
	solidity: {
		version: '0.8.7',
		settings: {
			optimizer: {
				enabled: true,
				runs: 200,
			},
		},
	},
	networks: {
		hardhat: {
			// Hardhat-specific configurations
		},
		sepolia: {
			url: SEPOLIA_RPC_URL,
			accounts: [`0x${PRIVATE_KEY}`],
		},
	},
	etherscan: {
		apiKey: ETHERSCAN_API_KEY,
	},
	mocha: {
		// Mocha test settings if needed.
	},
};
