import { useState, useEffect, useCallback } from 'react';
import { ethers } from 'ethers';

export const useEthereum = () => {
	const [address, setAddress] = useState(null);
	const [balance, setBalance] = useState(null);
	const [isConnected, setIsConnected] = useState(false);

	const connectWallet = useCallback(async () => {
		if (window.ethereum) {
			try {
				const provider = new ethers.providers.Web3Provider(window.ethereum);
				await provider.send('eth_requestAccounts', []);
				const signer = provider.getSigner();
				const address = await signer.getAddress();
				const balance = await provider.getBalance(address);

				setAddress(address);
				setBalance(ethers.utils.formatEther(balance));
				setIsConnected(true);
			} catch (error) {
				console.error('Error connecting to MetaMask:', error);
			}
		} else {
			alert('Please install MetaMask!');
		}
	}, []);

	useEffect(() => {
		connectWallet();
	}, [connectWallet]);

	return { address, balance, isConnected, connectWallet };
};
