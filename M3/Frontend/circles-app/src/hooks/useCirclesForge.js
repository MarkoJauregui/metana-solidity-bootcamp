import { useContext } from 'react';
import { Web3Context } from './Web3Context';
import CirclesForge from './abis/CirclesForge.json';

export const useCirclesForge = () => {
	const { web3, account } = useContext(Web3Context);
	const forgeContract = new web3.eth.Contract(
		CirclesForge.abi,
		CirclesForge.address
	);

	const forgeToken3 = async (amount) => {
		const tx = await forgeContract.methods
			.forgeToken3(amount)
			.send({ from: account });
		await tx.wait();
	};

	const forgeToken4 = async (amount) => {
		const tx = await forgeContract.methods
			.forgeToken4(amount)
			.send({ from: account });
		await tx.wait();
	};

	const forgeToken5 = async (amount) => {
		const tx = await forgeContract.methods
			.forgeToken5(amount)
			.send({ from: account });
		await tx.wait();
	};

	const forgeToken6 = async (amount) => {
		const tx = await forgeContract.methods
			.forgeToken6(amount)
			.send({ from: account });
		await tx.wait();
	};

	const mintTokensForContract = async (tokenId, amount) => {
		const tx = await forgeContract.methods
			.mintTokensForContract(tokenId, amount)
			.send({ from: account });
		await tx.wait();
	};

	return {
		forgeToken3,
		forgeToken4,
		forgeToken5,
		forgeToken6,
		mintTokensForContract,
	};
};
