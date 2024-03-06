import React from 'react';
import ConnectWalletButton from '@/components/ConnectWalletButton';
import WalletInfo from '@/components/WalletInfo';
import DepositAndMintForm from '@/components/DepositAndMintForm';
import { useEthereum } from '@/hooks/useEthereum';

export default function Home() {
	const { address, isConnected } = useEthereum(); // Use isConnected here

	return (
		<div className="container mx-auto p-4">
			<h1 className="text-5xl font-bold text-center text-blue-600 my-8">
				Metana Stable Coin
			</h1>
			{!isConnected ? (
				<ConnectWalletButton />
			) : (
				<>
					<WalletInfo />
					<DepositAndMintForm userAddress={address} />
				</>
			)}
		</div>
	);
}
