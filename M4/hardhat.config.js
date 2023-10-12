require('@nomiclabs/hardhat-waffle');
require('@nomiclabs/hardhat-ethers');
require('solidity-coverage');

// Include any other plugins you might need

module.exports = {
	defaultNetwork: 'hardhat',
	networks: {
		hardhat: {
			// Configuration for the local hardhat network
			chainId: 1337,
		},
		// Add configurations for other networks like mainnet, ropsten, etc., if needed
	},
	solidity: {
		compilers: [
			{
				version: '0.8.20', // Adjust this to match your contract's pragma statement
				settings: {
					optimizer: {
						enabled: true,
						runs: 200,
					},
				},
			},
			// Add other compiler versions if your project requires multiple versions
		],
	},
	paths: {
		artifacts: './artifacts',
		cache: './cache',
		sources: './contracts',
		tests: './test',
	},
	mocha: {
		timeout: 40000,
	},
	// Add other configurations if necessary
};
