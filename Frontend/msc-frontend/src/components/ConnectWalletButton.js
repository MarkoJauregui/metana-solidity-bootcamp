// components/ConnectWalletButton.js
import React from 'react';
import { useEthereum } from '@/hooks/useEthereum';

const ConnectWalletButton = () => {
	const { connectWallet, isConnected } = useEthereum();

	return (
		<div>
			{!isConnected ? (
				<button
					onClick={connectWallet}
					className="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded"
				>
					Connect Wallet
				</button>
			) : (
				<p className="text-green-500">Wallet Connected</p>
			)}
		</div>
	);
};

export default ConnectWalletButton;
