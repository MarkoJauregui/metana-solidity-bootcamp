import React, { useContext, useState } from 'react';
import { Web3Context } from '../../contexts/Web3Context';

function UserInfo() {
	const { signer, circlesERC1155, address } = useContext(Web3Context);
	const [selectedTokenId, setSelectedTokenId] = useState(0);
	const [tokenBalance, setTokenBalance] = useState(0);

	const fetchBalance = async () => {
		if (circlesERC1155 && signer && address) {
			const balance = await circlesERC1155.balanceOf(address, selectedTokenId);
			setTokenBalance(balance.toString());
		}
	};

	return (
		<div className="container mx-auto p-4">
			<div className="mb-4">
				<label
					className="block text-gray-700 text-sm font-bold mb-2"
					htmlFor="tokenId"
				>
					Token ID:
				</label>
				<select
					className="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
					id="tokenId"
					value={selectedTokenId}
					onChange={(e) => setSelectedTokenId(e.target.value)}
				>
					{[...Array(7).keys()].map((value) => (
						<option key={value} value={value}>
							{value}
						</option>
					))}
				</select>
			</div>
			<button
				className="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline-blue active:bg-blue-800"
				onClick={fetchBalance}
			>
				Fetch Balance
			</button>
			<div className="mt-4">
				<p className="text-gray-700">
					Balance for Token {selectedTokenId}:{' '}
					<span className="font-bold">{tokenBalance}</span>
				</p>
			</div>
		</div>
	);
}

export default UserInfo;
