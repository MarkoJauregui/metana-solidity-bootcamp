// index.js
import React from 'react';
import ConnectWalletButton from '@/components/ConnectWalletButton';
import WalletInfo from '@/components/WalletInfo';
import DepositAndMintForm from '@/components/DepositAndMintForm';
import RedeemCollateralForm from '@/components/RedeemCollateralForm';
import { useEthereum } from '@/hooks/useEthereum';
export default function Home() {
	const { address, isConnected } = useEthereum();

	return (
		<div className="container mx-auto p-4">
			<h1 className="text-2xl font-bold text-center mb-8">
				Metana Stable Coin
			</h1>
			<div className="flex flex-col items-center space-y-8">
				<div className="w-full md:w-2/3 lg:w-1/2 xl:w-1/3">
					{/* Wallet Info always visible when connected */}
					{isConnected && <WalletInfo />}
					{!isConnected ? (
						<ConnectWalletButton />
					) : (
						<>
							<br />
							<DepositAndMintForm userAddress={address} />
							<br />
							<RedeemCollateralForm userAddress={address} />
							{/* Additional components can be added here */}
						</>
					)}
				</div>
			</div>
		</div>
	);
}
