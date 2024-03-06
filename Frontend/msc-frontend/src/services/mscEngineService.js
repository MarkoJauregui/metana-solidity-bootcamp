import { ethers } from 'ethers';
import { MSCEngineABI, WETHABI, contractAddresses } from '../config/contracts';

// Helper function to get a provider or signer
const getProviderOrSigner = (needSigner = false) => {
	const provider = new ethers.providers.Web3Provider(window.ethereum);
	return needSigner ? provider.getSigner() : provider;
};

// Initialize the MSCEngine contract
const mscEngineContract = () => {
	const provider = getProviderOrSigner();
	return new ethers.Contract(
		contractAddresses.mscEngine,
		MSCEngineABI,
		provider
	);
};

// Function to approve WETH
export const approveWETH = async (amount, userAddress) => {
	const signer = getProviderOrSigner(true);
	const wethContractInstance = new ethers.Contract(
		contractAddresses.wETH,
		WETHABI,
		signer
	);
	const amountToApprove = ethers.utils.parseEther(amount);
	await wethContractInstance.approve(
		contractAddresses.mscEngine,
		amountToApprove
	);
	console.log('WETH approval successful');
};

// Function to deposit collateral and mint MSC
export const depositCollateralAndMintMsc = async (
	amountCollateral,
	amountMscToMint,
	userAddress
) => {
	const signer = getProviderOrSigner(true);
	const contract = mscEngineContract().connect(signer);
	await contract.depositCollateralAndMintMsc(
		contractAddresses.wETH,
		ethers.utils.parseEther(amountCollateral),
		ethers.utils.parseEther(amountMscToMint)
	);
	console.log('Collateral deposited and MSC minted');
};

export const getUsdValue = async (tokenAddress, amountInWei) => {
	try {
		const provider = getProviderOrSigner();
		const contract = mscEngineContract(provider);
		const usdValue = await contract.getUsdValue(tokenAddress, amountInWei);
		return ethers.utils.formatUnits(usdValue, 'ether'); // Assuming the contract returns the value in wei
	} catch (error) {
		console.error('Error fetching USD value:', error);
		throw error;
	}
};
