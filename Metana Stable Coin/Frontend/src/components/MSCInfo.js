import React, { useEffect, useState } from 'react';
import { getTotalSupply } from '../services/mscEngineService';
import { contractAddresses } from '../config/contracts';

const MSCInfo = () => {
	const [totalSupply, setTotalSupply] = useState('');

	useEffect(() => {
		const fetchTotalSupply = async () => {
			try {
				const supply = await getTotalSupply();
				setTotalSupply(supply);
			} catch (error) {
				console.error('Error fetching total supply:', error);
			}
		};

		fetchTotalSupply();
	}, []);

	return (
		<div className="mx-auto max-w-lg w-full p-5 shadow-lg rounded-lg bg-white">
			<h2 className="text-lg font-semibold">MSC Information</h2>
			<p>Total Supply: {totalSupply} MSC</p>
			<p>
				MSCEngine Contract:{' '}
				<a
					href="https://sepolia.etherscan.io/address/0x1d3c86edfb5a98e4fc843bf2fa55aec1a19f73cf"
					target="_blank"
					rel="noopener noreferrer"
				>
					0x1d3c86edfb5a98e4fc843bf2fa55aec1a19f73cf
				</a>
			</p>
			<p>
				MSC Contract:{' '}
				<a
					href="https://sepolia.etherscan.io/address/0x77a161deb9ef9dc33d8774a6f607f53450979e43"
					target="_blank"
					rel="noopener noreferrer"
				>
					0x77a161deb9ef9dc33d8774a6f607f53450979e43
				</a>
			</p>
		</div>
	);
};

export default MSCInfo;
