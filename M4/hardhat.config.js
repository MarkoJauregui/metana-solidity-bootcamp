require('@nomiclabs/hardhat-waffle');
require('@nomiclabs/hardhat-ethers');

module.exports = {
	defaultNetwork: 'hardhat',
	networks: {
		hardhat: {
			accounts: {
				mnemonic: 'test test test test test test test test test test test junk',
			},
			gasPrice: 20000000000,
			initialBaseFeePerGas: 0,
		},
	},
	solidity: {
		compilers: [
			{
				version: '0.8.0',
				settings: {
					optimizer: {
						enabled: true,
						runs: 200,
					},
				},
			},
			{
				version: '0.8.20',
				settings: {
					optimizer: {
						enabled: true,
						runs: 200,
					},
				},
			},
		],
	},
};
