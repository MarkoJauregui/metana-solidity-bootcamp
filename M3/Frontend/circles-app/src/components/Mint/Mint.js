import React, { useState, useContext } from 'react';
import { Web3Context } from '../../contexts/Web3Context';

function Mint() {
	const { circlesERC1155, signer, address } = useContext(Web3Context);
	const [selectedTokenId, setSelectedTokenId] = useState('0');
	const [amount, setAmount] = useState(1);
	const [mintedMessage, setMintedMessage] = useState('');
	const [error, setError] = useState('');

	const handleMint = async () => {
		if (circlesERC1155 && signer && address) {
			try {
				const tx = await circlesERC1155.mint(address, selectedTokenId, amount);
				const receipt = await tx.wait();

				// Find the Minted event from the transaction receipt
				const mintedEvent = receipt.events?.find((e) => e.event === 'Minted');

				if (mintedEvent) {
					setMintedMessage(
						`Minted ${mintedEvent.args.amount} tokens of ID ${mintedEvent.args.tokenId}!`
					);
					setError('');
				} else {
					setError('Minted successfully, but could not find the Minted event.');
				}
			} catch (error) {
				setError('Error minting token: ' + error.message);
				setMintedMessage('');
			}
		}
	};

	return (
		<div className="container mx-auto p-4">
			<h1 className="text-2xl font-semibold mb-4">Mint Tokens</h1>

			{mintedMessage && (
				<div className="bg-green-200 border-l-4 border-green-500 py-2 px-4 mb-4">
					{mintedMessage}
				</div>
			)}

			{error && (
				<div className="bg-red-200 border-l-4 border-red-500 py-2 px-4 mb-4">
					{error}
				</div>
			)}

			<div className="mb-4">
				<label htmlFor="tokenId" className="block font-medium mb-2">
					Select Token ID:
				</label>
				<select
					id="tokenId"
					className="border border-gray-300 rounded-md p-2"
					value={selectedTokenId}
					onChange={(e) => setSelectedTokenId(e.target.value)}
				>
					<option value="0">Token ID 0</option>
					<option value="1">Token ID 1</option>
					<option value="2">Token ID 2</option>
				</select>
			</div>

			<div className="mb-4">
				<label htmlFor="amount" className="block font-medium mb-2">
					Amount:
				</label>
				<input
					type="number"
					id="amount"
					className="border border-gray-300 rounded-md p-2"
					value={amount}
					onChange={(e) => setAmount(parseInt(e.target.value))}
				/>
			</div>

			<button
				onClick={handleMint}
				className="bg-blue-500 text-white py-2 px-4 rounded hover:bg-blue-600 cursor-pointer"
			>
				Mint Tokens
			</button>
		</div>
	);
}

export default Mint;
