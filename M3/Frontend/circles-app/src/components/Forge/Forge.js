import React, { useState, useContext } from 'react';
import { Web3Context } from '../../contexts/Web3Context';

const Forge = () => {
	const { address, circlesForge } = useContext(Web3Context);
	const [message, setMessage] = useState('');

	const handleForge = async (forgeFunctionName) => {
		try {
			const tx = await circlesForge[forgeFunctionName]();
			await tx.wait();
			setMessage(`Successfully forged using ${forgeFunctionName}!`);
		} catch (error) {
			// Try to get the revert reason if the transaction failed
			try {
				await circlesForge.callStatic[forgeFunctionName]();
			} catch (callError) {
				setMessage(`Error: ${callError.message}`);
				return;
			}
			setMessage(`Error: ${error.message}`);
		}
	};

	return (
		<div className="p-4">
			<h1 className="text-2xl font-semibold mb-4">Forge Tokens</h1>

			<button
				className="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded m-2"
				onClick={() => handleForge('forgeToken3')}
			>
				Forge Token 3
			</button>

			<button
				className="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded m-2"
				onClick={() => handleForge('forgeToken4')}
			>
				Forge Token 4
			</button>

			<button
				className="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded m-2"
				onClick={() => handleForge('forgeToken5')}
			>
				Forge Token 5
			</button>

			<button
				className="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded m-2"
				onClick={() => handleForge('forgeToken6')}
			>
				Forge Token 6
			</button>

			{message && <div className="mt-4 text-green-500">{message}</div>}
		</div>
	);
};

export default Forge;
