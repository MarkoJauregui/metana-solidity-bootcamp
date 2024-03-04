import React from 'react';
import { useWallet } from '../hooks/useWallet';
import { useEthBalance } from '../hooks/useEthBalance';
import { formatAddress, formatBalance } from '../utils/format';

const WalletInfo = () => {
	const { address, connectWallet } = useWallet();
	const { balance } = useEthBalance(address);

	return (
		<div>
			{address ? (
				<>
					<div>Address: {formatAddress(address)}</div>
					<div>Balance: {formatBalance(balance)} ETH</div>
				</>
			) : (
				<button onClick={connectWallet}>Connect Wallet</button>
			)}
		</div>
	);
};

export default WalletInfo;
