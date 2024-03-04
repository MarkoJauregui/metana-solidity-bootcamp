import { useState } from 'react';
import { ethers } from 'ethers';

export const useWallet = () => {
	const [address, setAddress] = useState(null);

	const connectWallet = async () => {
		if (typeof window.ethereum !== 'undefined') {
			try {
				const provider = new ethers.providers.Web3Provider(window.ethereum);
				// Request account access if needed
				await provider.send('eth_requestAccounts', []);
				// Get the user's address
				const signer = provider.getSigner();
				const userAddress = await signer.getAddress();
				setAddress(userAddress);
			} catch (error) {
				console.error(error);
			}
		} else {
			console.log('MetaMask is not installed!');
		}
	};

	return { address, connectWallet };
};
