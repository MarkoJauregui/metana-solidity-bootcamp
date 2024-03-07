import React, { useEffect, useState } from 'react';
import { useEthereum } from '../hooks/useEthereum';
import {
	getAccountInformation,
	getCollateralBalanceOfUser,
} from '../services/mscEngineService';
import { formatNumber, formatCurrency } from '../utils/format';
import { contractAddresses } from '../config/contracts'; // Ensure this import path is correct

const WalletInfo = () => {
	const { address } = useEthereum();
	const [mscBalance, setMscBalance] = useState('0');
	const [collateralInWeth, setCollateralInWeth] = useState('0');
	const [collateralInUsd, setCollateralInUsd] = useState('0');

	useEffect(() => {
		if (address) {
			fetchAccountInformation(address);
			fetchCollateralBalance(address);
		}
	}, [address]);

	const fetchAccountInformation = async (userAddress) => {
		try {
			const { totalMscMinted, collateralValueInUsd } =
				await getAccountInformation(userAddress);
			setMscBalance(formatNumber(totalMscMinted, true)); // No decimals for MSC balance
			setCollateralInUsd(formatCurrency(collateralValueInUsd, 'USD', 2)); // USD formatting
		} catch (error) {
			console.error('Failed to fetch account information:', error);
		}
	};

	const fetchCollateralBalance = async (userAddress) => {
		try {
			const wethCollateralWei = await getCollateralBalanceOfUser(
				userAddress,
				contractAddresses.wETH
			);
			const wethCollateral = ethers.utils.formatEther(wethCollateralWei);
			setCollateralInWeth(formatNumber(wethCollateral, false)); // Adjust decimal places as needed
		} catch (error) {
			console.error('Failed to fetch WETH collateral balance:', error);
		}
	};

	return (
		<div className="max-w-lg mx-auto p-5 shadow-lg rounded-lg bg-white">
			<h2 className="text-lg font-semibold text-gray-800 mb-4">
				Wallet Information
			</h2>
			<div className="text-gray-700">
				<p>
					<span className="font-medium">Address:</span> {address}
				</p>
				<p>
					<span className="font-medium">MSC Balance:</span> {mscBalance} MSC
				</p>
				<p>
					<span className="font-medium">Collateral:</span> {collateralInWeth}{' '}
					WETH (~ {collateralInUsd})
				</p>
			</div>
		</div>
	);
};

export default WalletInfo;
