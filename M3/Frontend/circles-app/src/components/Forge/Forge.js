import React, { useState, useEffect, useContext } from 'react';
import { Web3Context } from '../../contexts/Web3Context';

const Forge = () => {
	const { address, circlesForge } = useContext(Web3Context);

	const [token1, setToken1] = useState(0);
	const [token2, setToken2] = useState(1);
	const [amount, setAmount] = useState(1);
	const [message, setMessage] = useState('');

	const getForgeFunction = (token1, token2) => {
		const combination = [token1, token2].sort().join(',');
		const forgeMap = {
			'0,1': 'forgeToken3',
			'1,2': 'forgeToken4',
			'0,2': 'forgeToken5',
			'0,1,2': 'forgeToken6',
		};
		return forgeMap[combination];
	};

	const handleForge = async () => {
		const forgeFunctionName = getForgeFunction(token1, token2);

		if (!forgeFunctionName) {
			setMessage('Invalid token combination selected.');
			return;
		}

		try {
			const tx = await circlesForge[forgeFunctionName](amount);
			await tx.wait();

			setMessage('Tokens successfully forged!');
		} catch (error) {
			setMessage(`Error: Not enough balance of both tokens`);
		}
	};

	useEffect(() => {
		if (!circlesForge) return; // <- Check if circlesForge is initialized

		const onTokenForged = (user, tokenId, amount) => {
			if (user.toLowerCase() === address.toLowerCase()) {
				setMessage(
					`Successfully forged token ${tokenId} with amount ${amount}!`
				);
			}
		};

		circlesForge.on('TokenForged', onTokenForged);

		return () => {
			circlesForge.off('TokenForged', onTokenForged);
		};
	}, [address, circlesForge]);

	return (
		<div className="p-4">
			<h1 className="text-2xl font-semibold mb-4">Forge Tokens</h1>

			<div className="mb-3">
				<label className="mr-2">Select Token 1: </label>
				<select
					className="border p-2 rounded"
					value={token1}
					onChange={(e) => setToken1(Number(e.target.value))}
				>
					<option value={0}>Token 0</option>
					<option value={1}>Token 1</option>
					<option value={2}>Token 2</option>
				</select>
			</div>

			<div className="mb-3">
				<label className="mr-2">Select Token 2: </label>
				<select
					className="border p-2 rounded"
					value={token2}
					onChange={(e) => setToken2(Number(e.target.value))}
				>
					<option value={0}>Token 0</option>
					<option value={1}>Token 1</option>
					<option value={2}>Token 2</option>
				</select>
			</div>

			<div className="mb-3">
				<label className="mr-2">Amount: </label>
				<input
					className="border p-2 rounded"
					type="number"
					value={amount}
					onChange={(e) => setAmount(Number(e.target.value))}
				/>
			</div>

			<button
				className="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded"
				onClick={handleForge}
			>
				Forge
			</button>

			{message && <div className="mt-4 text-green-500">{message}</div>}
		</div>
	);
};

export default Forge;
