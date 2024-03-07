import React, { useState, useEffect } from 'react';
import {
	approveWETH,
	depositCollateralAndMintMsc,
	getUsdValue,
} from '../services/mscEngineService';
import { contractAddresses } from '../config/contracts';
import { useEthereum } from '../hooks/useEthereum';
import { ethers } from 'ethers';

const DepositAndMintForm = () => {
	const [ethAmount, setEthAmount] = useState('');
	const [mscAmount, setMscAmount] = useState('');
	const [maxMsc, setMaxMsc] = useState('0');
	const { address } = useEthereum();
	const [isApproved, setIsApproved] = useState(false);

	useEffect(() => {
		const fetchMaxMsc = async () => {
			if (!ethAmount) {
				setMaxMsc('0');
				return;
			}
			try {
				const amountInWei = ethers.utils.parseUnits(ethAmount, 'ether');
				const usdValue = await getUsdValue(contractAddresses.wETH, amountInWei);
				const maxMscToMint = Math.floor(usdValue / 2); // Ensure over-collateralization and round down
				setMaxMsc(maxMscToMint.toString());
			} catch (error) {
				console.error('Error fetching USD value:', error);
				setMaxMsc('0');
			}
		};

		fetchMaxMsc();
	}, [ethAmount]);

	const handleApprove = async () => {
		if (!ethAmount || !address) return;

		try {
			await approveWETH(ethAmount, address);
			setIsApproved(true);
			console.log('WETH approval successful');
		} catch (error) {
			console.error('Error approving WETH:', error);
		}
	};

	const handleDepositAndMint = async () => {
		if (
			!ethAmount ||
			!mscAmount ||
			!address ||
			parseFloat(mscAmount) > parseFloat(maxMsc)
		)
			return;

		try {
			await depositCollateralAndMintMsc(ethAmount, mscAmount, address);
			console.log('Collateral deposited and MSC minted successfully');
			setEthAmount('');
			setMscAmount('');
			setMaxMsc('0');
			setIsApproved(false); // Reset approval status
		} catch (error) {
			console.error('Error depositing collateral and minting MSC:', error);
		}
	};

	return (
		<div className="space-y-4">
			<div className="mx-auto max-w-lg w-full p-5 shadow-lg rounded-lg bg-white">
				<h2 className="text-xl font-semibold text-center text-blue-600">
					Deposit and Minting
				</h2>
				<div>
					<label
						htmlFor="ethAmount"
						className="block text-sm font-medium text-gray-700"
					>
						wETH Amount to Deposit
					</label>
					<input
						type="number"
						id="ethAmount"
						value={ethAmount}
						onChange={(e) => setEthAmount(e.target.value)}
						placeholder="Enter wETH amount"
						className="mt-1 block w-full px-3 py-2 bg-white border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
					/>
				</div>
				<div>
					<label
						htmlFor="mscAmount"
						className="block text-sm font-medium text-gray-700"
					>
						MSC Amount to Mint
					</label>
					<input
						type="number"
						id="mscAmount"
						value={mscAmount}
						onChange={(e) => setMscAmount(e.target.value)}
						placeholder="Enter MSC amount"
						disabled={!isApproved} // Disable MSC input until WETH is approved
						className="mt-1 block w-full px-3 py-2 bg-white border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500 disabled:bg-gray-200"
					/>
					<p className="mt-2 text-sm text-gray-500">
						Maximum MSC you can mint: {maxMsc}
					</p>
				</div>
				<div className="flex space-x-2">
					<button
						onClick={handleApprove}
						disabled={isApproved || !ethAmount}
						className="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600 disabled:bg-blue-300"
					>
						Approve WETH
					</button>
					<button
						onClick={handleDepositAndMint}
						disabled={!isApproved || parseFloat(mscAmount) > parseFloat(maxMsc)}
						className="px-4 py-2 bg-green-500 text-white rounded hover:bg-green-600 disabled:bg-green-300"
					>
						Deposit and Mint
					</button>
				</div>
			</div>
		</div>
	);
};

export default DepositAndMintForm;
