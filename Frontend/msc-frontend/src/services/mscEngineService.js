import { ethers } from 'ethers';
import {
	MSCEngineABI,
	MetanaStableCoinABI,
	WETHABI,
	contractAddresses,
} from '../config/contracts';

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

// Initialize the MetanaStableCoin contract
const metanaStableCoinContract = (signerOrProvider) => {
	return new ethers.Contract(
		contractAddresses.metanaStableCoin,
		MetanaStableCoinABI,
		signerOrProvider
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

// Assuming MSCEngineABI and contractAddresses are already imported

export const getAccountInformation = async (userAddress) => {
	const provider = getProviderOrSigner();
	const contract = new ethers.Contract(
		contractAddresses.mscEngine,
		MSCEngineABI,
		provider
	);
	try {
		const [totalMscMinted, collateralValueInUsd] =
			await contract.getAccountInformation(userAddress);
		return {
			totalMscMinted: ethers.utils.formatUnits(totalMscMinted, 'ether'), // Adjust based on your token's decimals
			collateralValueInUsd: ethers.utils.formatUnits(
				collateralValueInUsd,
				'ether'
			), // Assuming USD value is also in wei format
		};
	} catch (error) {
		console.error('Error fetching account information:', error);
		throw error;
	}
};

// Function to approve MSC
export const approveMSC = async (amount, userAddress) => {
	const signer = getProviderOrSigner(true);
	const mscContract = metanaStableCoinContract(signer);
	const amountToApprove = ethers.utils.parseEther(amount.toString());
	const tx = await mscContract.approve(
		contractAddresses.mscEngine,
		amountToApprove
	);
	await tx.wait();
	console.log('MSC approval successful');
};

// Function to redeem collateral and burn MSC
export const redeemCollateralForMsc = async (
	wethAmount,
	mscAmount,
	userAddress
) => {
	const signer = getProviderOrSigner(true);
	const engineContract = new ethers.Contract(
		contractAddresses.mscEngine,
		MSCEngineABI,
		signer
	);
	const wethAmountInWei = ethers.utils.parseEther(wethAmount.toString());
	const mscAmountInWei = ethers.utils.parseEther(mscAmount.toString());
	const tx = await engineContract.reedemCollateralForMsc(
		contractAddresses.wETH,
		wethAmountInWei,
		mscAmountInWei
	);
	await tx.wait();
	console.log('Collateral redeemed and MSC burned successfully');
};
