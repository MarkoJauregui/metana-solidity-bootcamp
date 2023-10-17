import { createContext, useState, useEffect } from 'react';
import { ethers } from 'ethers';

import circlesERC1155Data from '../abis/CirclesERC1155.json';
import circlesForgeData from '../abis/CirclesForge.json';

import contractAddresses from '../contractConfig';

export const Web3Context = createContext();

export function Web3ProviderComponent({ children }) {
	const circlesERC1155ABI = circlesERC1155Data.abi;
	const circlesForgeABI = circlesForgeData.abi;

	const [provider, setProvider] = useState(null);
	const [signer, setSigner] = useState(null);
	const [address, setAddress] = useState(null);
	const [circlesERC1155, setCirclesERC1155] = useState(null);
	const [circlesForge, setCirclesForge] = useState(null);
	const [networkId, setNetworkId] = useState(null);

	const MUMBAI_NETWORK_PARAMS = {
		chainId: '0x13881', // This is the chainId for Mumbai in hexadecimal
		chainName: 'Mumbai Testnet',
		nativeCurrency: {
			name: 'MATIC',
			symbol: 'MATIC',
			decimals: 18,
		},
		rpcUrls: ['https://rpc-mumbai.maticvigil.com/'],
		blockExplorerUrls: ['https://explorer-mumbai.maticvigil.com/'],
	};

	useEffect(() => {
		if (typeof window.ethereum !== 'undefined') {
			const _provider = new ethers.providers.Web3Provider(window.ethereum);
			setProvider(_provider);
			const _signer = _provider.getSigner();
			setSigner(_signer);
			const _circlesERC1155 = new ethers.Contract(
				contractAddresses.CirclesERC1155,
				circlesERC1155ABI,
				_signer
			);
			const _circlesForge = new ethers.Contract(
				contractAddresses.CirclesForge,
				circlesForgeABI,
				_signer
			);
			setCirclesERC1155(_circlesERC1155);
			setCirclesForge(_circlesForge);

			// Get and set the network ID
			_provider.getNetwork().then((net) => {
				setNetworkId(net.chainId);
			});
		} else {
			// If Metamask is not installed, fall back to Infura
			const infuraProvider = new ethers.providers.JsonRpcProvider(
				process.env.REACT_APP_INFURA_URL
			);
			setProvider(infuraProvider);
		}
	}, []);

	const connectWallet = async () => {
		if (provider) {
			const accounts = await window.ethereum.request({
				method: 'eth_requestAccounts',
			});
			setAddress(accounts[0]);

			// Check current network and switch to Mumbai if necessary
			if (networkId !== 80001) {
				try {
					await window.ethereum.request({
						method: 'wallet_addEthereumChain',
						params: [MUMBAI_NETWORK_PARAMS],
					});
					// After switching, you can update the networkId state again
					const _networkId = await provider
						.getNetwork()
						.then((net) => net.chainId);
					setNetworkId(_networkId);
				} catch (error) {
					console.error('Failed to switch to the Mumbai network:', error);
				}
			}
		} else {
			console.error('Ethereum provider is not available.');
		}
	};

	return (
		<Web3Context.Provider
			value={{
				provider,
				signer,
				connectWallet,
				address,
				circlesERC1155,
				circlesForge,
			}}
		>
			{children}
		</Web3Context.Provider>
	);
}
