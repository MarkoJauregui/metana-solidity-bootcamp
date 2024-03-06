// src/components/WalletInfo.js
import React from 'react';
import { useEthereum } from '../hooks/useEthereum';

const WalletInfo = () => {
	const { address, balance } = useEthereum();

	const formatAddress = (address) =>
		`${address.substring(0, 6)}...${address.substring(address.length - 4)}`;

	// components/WalletInfo.js
	return (
		<div className="mt-4 p-4 bg-gray-100 rounded-lg shadow">
			{address ? (
				<>
					<p className="text-lg font-semibold">
						Address: {formatAddress(address)}
					</p>
					<p className="text-lg">
						Balance: {parseFloat(balance).toFixed(4)} ETH
					</p>
				</>
			) : (
				<p className="text-red-500">Connect your wallet to view information.</p>
			)}
		</div>
	);
};

export default WalletInfo;
