import React from 'react';
import { useWeb3 } from '../../contexts/Web3Context';

function ConnectWalletButton() {
	const { provider } = useWeb3();

	const connectWallet = async () => {
		if (!provider) return;
		await window.ethereum.request({ method: 'eth_requestAccounts' });
		window.location.reload(); // Refresh page to get the updated state
	};

	return <button onClick={connectWallet}>Connect Wallet</button>;
}

export default ConnectWalletButton;
