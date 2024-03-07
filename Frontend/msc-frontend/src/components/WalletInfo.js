import React, { useEffect, useState } from 'react';
import { useEthereum } from '../hooks/useEthereum';
import { getAccountInformation } from '../services/mscEngineService';
import { formatNumber, formatCurrency } from '../utils/format';

const WalletInfo = () => {
	const { address } = useEthereum();
	const [mscBalance, setMscBalance] = useState('0');
	const [collateral, setCollateral] = useState('0');

	useEffect(() => {
		if (address) {
			fetchAccountInformation(address);
		}
	}, [address]);

	const fetchAccountInformation = async (userAddress) => {
		try {
			const { totalMscMinted, collateralValueInUsd } =
				await getAccountInformation(userAddress);
			// Use Math.floor to round down the MSC balance to the nearest whole number
			setMscBalance(formatNumber(totalMscMinted, true)); // true to indicate no decimals

			setCollateral(formatCurrency(collateralValueInUsd, '', 0)); // 0 decimals for USD formatting
		} catch (error) {
			console.error('Failed to fetch account information:', error);
		}
	};

	return (
		<div className="mx-auto max-w-lg w-full p-5 shadow-lg rounded-lg bg-white">
			<h2 className="text-lg font-semibold">Wallet Information</h2>
			<p>Address: {address}</p>
			<p>MSC Balance: {mscBalance} MSC</p>
			<p>Collateral (WETH): {collateral} USD</p>
			{/* Include other wallet info as needed */}
		</div>
	);
};

export default WalletInfo;
