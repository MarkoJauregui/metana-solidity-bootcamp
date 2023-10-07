import { useWeb3 } from '../contexts/Web3Context';
import circlesERC1155ABI from '../abis/CirclesERC1155.json'; // Make sure to provide the correct ABI filenames
import circlesForgeABI from '../abis/CirclesForge.json';
import { CirclesERC1155Address, CirclesForgeAddress } from '../config';

export function useCirclesERC1155Contract() {
	const { provider } = useWeb3();
	return new ethers.Contract(
		CirclesERC1155Address,
		circlesERC1155ABI,
		provider.getSigner()
	);
}

export function useCirclesForgeContract() {
	const { provider } = useWeb3();
	return new ethers.Contract(
		CirclesForgeAddress,
		circlesForgeABI,
		provider.getSigner()
	);
}
