import React, { useState, useEffect } from 'react';
import { ethers } from 'ethers';
import {
	approveMSC,
	redeemCollateralForMsc,
	getUsdValue,
	getAccountInformation,
} from '../services/mscEngineService';
import { contractAddresses } from '../config/contracts';
import { useEthereum } from '../hooks/useEthereum';

const RedeemCollateralForm = () => {
	const [wethAmount, setWethAmount] = useState('');
	const [mscToBurn, setMscToBurn] = useState('');
	const { address } = useEthereum();
	const [isApproved, setIsApproved] = useState(false);

	useEffect(() => {
		const fetchMscToBurn = async () => {
			if (!wethAmount) {
				setMscToBurn('0');
				return;
			}
			try {
				const amountInWei = ethers.utils.parseUnits(wethAmount, 'ether');
				const usdValue = await getUsdValue(contractAddresses.wETH, amountInWei);
				// Assuming 1 MSC = 1 USD for simplicity, adjust as needed
				const mscToBurnCalc = Math.floor(usdValue / 2); // Ensure over-collateralization and round down
				setMscToBurn(mscToBurnCalc.toString());
			} catch (error) {
				console.error('Error calculating MSC to burn:', error);
				setMscToBurn('0');
			}
		};

		fetchMscToBurn();
	}, [wethAmount]);

	const handleApprove = async () => {
		if (!mscToBurn || !address) return;

		try {
			await approveMSC(mscToBurn, address);
			setIsApproved(true);
			console.log('MSC approval successful');
		} catch (error) {
			console.error('Error approving MSC:', error);
		}
	};

	const handleRedeem = async () => {
		if (!wethAmount || !mscToBurn || !address) return;

		try {
			await redeemCollateralForMsc(wethAmount, mscToBurn, address);
			console.log('Collateral redeemed and MSC burned successfully');
			setWethAmount('');
			setMscToBurn('');
			setIsApproved(false); // Reset approval status
		} catch (error) {
			console.error('Error redeeming collateral and burning MSC:', error);
		}
	};

	return (
		<div className="space-y-4">
			<div className="mx-auto max-w-lg w-full p-5 shadow-lg rounded-lg bg-white">
				<h2 className="text-xl font-semibold text-center text-red-600">
					Collateral Redemption
				</h2>
				<div>
					<label
						htmlFor="wethAmount"
						className="block text-sm font-medium text-gray-700"
					>
						WETH Amount to Redeem
					</label>
					<input
						type="number"
						id="wethAmount"
						value={wethAmount}
						onChange={(e) => setWethAmount(e.target.value)}
						placeholder="Enter WETH amount"
						className="mt-1 block w-full px-3 py-2 bg-white border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500"
					/>
				</div>
				<div>
					<p className="text-sm font-medium text-gray-700">
						MSC You Should Burn: {mscToBurn}
					</p>
				</div>
				<div className="flex space-x-2">
					<button
						onClick={handleApprove}
						disabled={isApproved || !mscToBurn}
						className="px-4 py-2 bg-indigo-500 text-white rounded hover:bg-indigo-600 disabled:bg-indigo-300"
					>
						Approve MSC
					</button>
					<button
						onClick={handleRedeem}
						disabled={!isApproved}
						className="px-4 py-2 bg-red-500 text-white rounded hover:bg-red-600 disabled:bg-red-300"
					>
						Redeem Collateral and Burn MSC
					</button>
				</div>
			</div>
		</div>
	);
};

export default RedeemCollateralForm;
