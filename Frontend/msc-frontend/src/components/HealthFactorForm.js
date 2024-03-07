import React, { useState } from 'react';
import { getHealthFactor } from '../services/mscEngineService'; // Ensure this function is correctly implemented

const HealthFactorForm = () => {
	const [inputAddress, setInputAddress] = useState('');
	const [healthFactor, setHealthFactor] = useState(null);
	const [healthFactorStatus, setHealthFactorStatus] = useState('');

	const fetchHealthFactor = async () => {
		try {
			const hf = await getHealthFactor(inputAddress);
			setHealthFactor(hf);
			setHealthFactorStatus(hf >= 1 ? 'Healthy' : 'At Risk of Liquidation');
		} catch (error) {
			console.error('Error fetching health factor:', error);
			setHealthFactor(null);
			setHealthFactorStatus('Error fetching health factor');
		}
	};

	return (
		<div className="mx-auto max-w-lg w-full p-5 shadow-lg rounded-lg bg-white">
			<h2 className="text-xl font-semibold text-center">Check Health Factor</h2>
			<div className="my-4">
				<input
					type="text"
					value={inputAddress}
					onChange={(e) => setInputAddress(e.target.value)}
					placeholder="Enter user address"
					className="mt-1 block w-full px-3 py-2 bg-white border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
				/>
			</div>
			<button
				onClick={fetchHealthFactor}
				className="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600"
			>
				Check Health Factor
			</button>
			{healthFactor !== null && (
				<div className="mt-4">
					<p>
						Your health factor is currently: {Number(healthFactor).toFixed(2)}
					</p>
					<p className={healthFactor >= 1 ? 'text-green-500' : 'text-red-500'}>
						{healthFactorStatus}
					</p>
				</div>
			)}
		</div>
	);
};

export default HealthFactorForm;
