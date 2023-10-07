import React, { useState } from 'react';
import { Web3Provider } from '@ethersproject/providers';
import CirclesERC1155ABI from '../../abis/CirclesERC1155.json';
import { CirclesERC1155Address } from '../../config';

const MintTokens = () => {
	const [provider, setProvider] = useState(new Web3Provider(window.ethereum));
	const [userAddress, setUserAddress] = useState(null);
	const [amount, setAmount] = useState(1);
	const [mintingMessage, setMintingMessage] = useState('');

	if (window.ethereum) {
		window.ethereum.on('accountsChanged', (accounts) => {
			setUserAddress(accounts[0]);
		});
	}

	const handleMint = async () => {
		if (!provider || !userAddress) {
			setMintingMessage('Please connect your wallet first.');
			return;
		}

		const contract = new ethers.Contract(
			CirclesERC1155Address,
			CirclesERC1155ABI,
			provider.getSigner()
		);

		const lastMintTimestamp = await contract.getLastMintTimestamp(
			userAddress,
			0
		);
		const cooldownElapsed =
			Date.now() / 1000 - lastMintTimestamp.toNumber() > 60;

		if (!cooldownElapsed) {
			setMintingMessage('Cooldown has not elapsed yet.');
			return;
		}

		try {
			const tx = await contract.mint(userAddress, 0, amount);
			await tx.wait();
			setMintingMessage('Tokens minted successfully!');
		} catch (error) {
			console.error('Error minting tokens:', error);
			setMintingMessage('Error minting tokens. See console for details.');
		}
	};

	return (
		<div>
			<h2>Mint Tokens Component</h2>
			<div>
				<label htmlFor="mintAmount">Amount:</label>
				<input
					type="number"
					id="mintAmount"
					value={amount}
					onChange={(e) => setAmount(e.target.value)}
				/>
				<button onClick={handleMint}>Mint Tokens</button>
			</div>
			{mintingMessage && <p>{mintingMessage}</p>}
		</div>
	);
};

export default MintTokens;
