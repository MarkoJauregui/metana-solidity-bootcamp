import React, { useState, useContext } from 'react';
import { Web3Context } from '../../contexts/Web3Context';

const Trade = () => {
	const [selectedTokenToTrade, setSelectedTokenToTrade] = useState('3');
	const [selectedTokenToReceive, setSelectedTokenToReceive] = useState('0');
	const { circlesERC1155 } = useContext(Web3Context);

	const tokenOptions = [
		{ label: 'Token 0', value: '0' },
		{ label: 'Token 1', value: '1' },
		{ label: 'Token 2', value: '2' },
		{ label: 'Token 3', value: '3' },
		{ label: 'Token 4', value: '4' },
		{ label: 'Token 5', value: '5' },
		{ label: 'Token 6', value: '6' },
	];

	const handleTrade = async () => {
		console.log(
			`Trading Token ${selectedTokenToTrade} for Token ${selectedTokenToReceive}`
		);

		try {
			// Assuming circlesERC1155 has a function tradeToken(tokenId, desiredToken)
			await circlesERC1155.tradeToken(
				selectedTokenToTrade,
				selectedTokenToReceive
			);
			console.log('Trade successful!');
		} catch (error) {
			console.error('Error trading tokens:', error.message);
		}
	};

	return (
		<div className="container mx-auto py-6">
			<h1 className="text-2xl font-semibold mb-4">Trade Tokens</h1>
			<div className="flex flex-col space-y-4">
				<label
					htmlFor="tokenToTrade"
					className="block text-sm font-medium text-gray-700"
				>
					Token to Trade
				</label>
				<select
					value={selectedTokenToTrade}
					onChange={(e) => setSelectedTokenToTrade(e.target.value)}
					className="mt-1 block w-full py-2 px-3 border rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500 sm:text-sm border-gray-300"
				>
					{tokenOptions.map((token, index) => (
						<option key={index} value={token.value}>
							{token.label}
						</option>
					))}
				</select>

				<label
					htmlFor="tokenToReceive"
					className="block text-sm font-medium text-gray-700"
				>
					Desired Token
				</label>
				<select
					value={selectedTokenToReceive}
					onChange={(e) => setSelectedTokenToReceive(e.target.value)}
					className="mt-1 block w-full py-2 px-3 border rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500 sm:text-sm border-gray-300"
				>
					{tokenOptions.slice(0, 3).map((token, index) => (
						<option key={index} value={token.value}>
							{token.label}
						</option>
					))}
				</select>

				<button
					className="w-full bg-blue-600 text-white p-2 rounded hover:bg-blue-700 focus:outline-none"
					onClick={handleTrade}
				>
					Trade Tokens
				</button>
			</div>
		</div>
	);
};

export default Trade;
