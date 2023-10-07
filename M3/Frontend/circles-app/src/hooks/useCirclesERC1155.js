import { useContext } from 'react';
import { Web3Context } from './Web3Context';
import CirclesERC1155 from './abis/CirclesERC1155.json';

export const useCirclesERC1155 = () => {
	const { web3, account } = useContext(Web3Context);
	const nftContract = new web3.eth.Contract(
		CirclesERC1155.abi,
		CirclesERC1155.address
	);

	const mintToken = async (tokenId, amount) => {
		const tx = await nftContract.methods
			.mint(account, tokenId, amount)
			.send({ from: account });
		await tx.wait();
	};

	const tradeToken = async (tokenId, desiredToken, amount) => {
		const tx = await nftContract.methods
			.tradeToken(tokenId, desiredToken, amount)
			.send({ from: account });
		await tx.wait();
	};

	const burnToken = async (tokenId, amount) => {
		const tx = await nftContract.methods
			.burn(account, tokenId, amount)
			.send({ from: account });
		await tx.wait();
	};

	return {
		mintToken,
		tradeToken,
		burnToken,
	};
};
