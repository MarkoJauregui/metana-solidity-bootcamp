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
		return ethers.utils.formatUnits(usdValue, 'ether');
	} catch (error) {
		console.error('Error fetching USD value:', error);
		throw error;
	}
};

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
			totalMscMinted: ethers.utils.formatUnits(totalMscMinted, 'ether'),
			collateralValueInUsd: ethers.utils.formatUnits(
				collateralValueInUsd,
				'ether'
			),
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

export const getHealthFactor = async (userAddress) => {
	const provider = getProviderOrSigner();
	const contract = mscEngineContract(provider);
	try {
		const healthFactor = await contract.getHealthFactor(userAddress);
		return ethers.utils.formatUnits(healthFactor, 'ether');
	} catch (error) {
		console.error('Error fetching health factor:', error);
		throw error;
	}
};

export const liquidate = async (
	collateralAddress,
	userAddress,
	debtToCover,
	liquidatorAddress
) => {
	const signer = getProviderOrSigner(true);
	const contract = mscEngineContract().connect(signer);
	try {
		const tx = await contract.liquidate(
			collateralAddress,
			userAddress,
			ethers.utils.parseEther(debtToCover),
			{
				from: liquidatorAddress,
			}
		);
		await tx.wait();
		console.log('Liquidation successful');
	} catch (error) {
		console.error('Error during liquidation:', error);
		throw error;
	}
};

export const getTotalSupply = async () => {
	const provider = getProviderOrSigner();
	// Make sure to use the correct key here as defined in your contractAddresses object
	const mscContract = new ethers.Contract(
		contractAddresses.metanaStableCoin, // This should match the key in your contractAddresses object
		MetanaStableCoinABI,
		provider
	);
	try {
		const totalSupply = await mscContract.totalSupply();
		return ethers.utils.formatEther(totalSupply);
	} catch (error) {
		console.error('Error fetching total supply:', error);
		throw error;
	}
};

export const getCollateralBalanceOfUser = async (userAddress, tokenAddress) => {
	const provider = getProviderOrSigner();
	const contract = new ethers.Contract(
		contractAddresses.mscEngine,
		MSCEngineABI,
		provider
	);
	try {
		const balanceWei = await contract.getCollateralBalanceOfUser(
			userAddress,
			tokenAddress
		);
		const balanceEther = ethers.utils.formatEther(balanceWei);
		return balanceEther; // This returns the balance in Ether, not Wei
	} catch (error) {
		console.error('Error fetching collateral balance:', error);
		throw error;
	}
};
