import React, { useState } from 'react';
import { liquidate } from '../services/mscEngineService';
import { contractAddresses } from '../config/contracts';
import { useEthereum } from '../hooks/useEthereum';

const LiquidateForm = () => {
	const [userAddress, setUserAddress] = useState('');
	const [debtToCover, setDebtToCover] = useState('');
	const { address: liquidatorAddress } = useEthereum();

	const handleLiquidation = async () => {
		if (!userAddress || !debtToCover) {
			alert('Please fill in all fields');
			return;
		}
		try {
			await liquidate(
				contractAddresses.wETH,
				userAddress,
				debtToCover,
				liquidatorAddress
			);
			alert('Liquidation successful');
		} catch (error) {
			alert(`Error during liquidation: ${error.message}`);
		}
	};

	return (
		<div className="mx-auto max-w-lg w-full p-5 shadow-lg rounded-lg bg-white">
			<h2 className="text-xl font-semibold text-center">Liquidate</h2>
			<div className="my-4">
				<input
					type="text"
					value={userAddress}
					onChange={(e) => setUserAddress(e.target.value)}
					placeholder="User Address"
					className="mt-1 block w-full px-3 py-2 bg-white border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
				/>
				<input
					type="text"
					value={debtToCover}
					onChange={(e) => setDebtToCover(e.target.value)}
					placeholder="Debt to Cover (ETH)"
					className="mt-1 block w-full px-3 py-2 bg-white border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
				/>
			</div>
			<button
				onClick={handleLiquidation}
				className="px-4 py-2 bg-red-500 text-white rounded hover:bg-red-600"
			>
				Liquidate
			</button>
		</div>
	);
};

export default LiquidateForm;
