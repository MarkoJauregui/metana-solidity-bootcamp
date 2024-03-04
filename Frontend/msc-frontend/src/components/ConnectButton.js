// components/ConnectButton.js
import { useState } from 'react';
import { ethers } from 'ethers';

export default function ConnectButton() {
	const [userAddress, setUserAddress] = useState('');

	async function connectWallet() {
		if (typeof window.ethereum !== 'undefined') {
			try {
				const [address] = await window.ethereum.request({
					method: 'eth_requestAccounts',
				});
				setUserAddress(address);
			} catch (error) {
				console.error(error);
			}
		} else {
			alert('MetaMask is not installed!');
		}
	}

	return (
		<div>
			{userAddress ? (
				<p>Connected as: {userAddress}</p>
			) : (
				<button
					onClick={connectWallet}
					className="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded"
				>
					Connect Wallet
				</button>
			)}
		</div>
	);
}
