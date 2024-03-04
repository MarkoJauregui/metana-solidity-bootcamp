// src/hooks/useEthBalance.js
import { useState, useEffect } from 'react';
import { ethers } from 'ethers';

export const useEthBalance = (address) => {
	const [balance, setBalance] = useState('0');

	useEffect(() => {
		if (!address) return;

		const provider = new ethers.providers.Web3Provider(window.ethereum);
		const getBalance = async () => {
			console.log(`Fetching balance for address: ${address}`);
			const balance = await provider.getBalance(address);
			const formattedBalance = ethers.utils.formatEther(balance);
			console.log(`Fetched balance: ${formattedBalance} ETH`);
			setBalance(formattedBalance);
		};

		getBalance();
	}, [address]);

	return { balance };
};
