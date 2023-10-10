import React, { useContext } from 'react';
import { Web3Context } from '../../contexts/Web3Context';

function ConnectButton() {
	const { connectWallet, address } = useContext(Web3Context);

	return (
		<button
			onClick={connectWallet}
			className="bg-blue-500 text-white font-bold py-2 px-4 rounded-full hover:bg-blue-700 active:bg-blue-900 focus:outline-none focus:border-blue-700 focus:shadow-outline-blue"
		>
			{address
				? `Connected: ${address.substring(0, 6)}...${address.substring(
						address.length - 4
				  )}`
				: 'Connect Wallet'}
		</button>
	);
}

export default ConnectButton;
