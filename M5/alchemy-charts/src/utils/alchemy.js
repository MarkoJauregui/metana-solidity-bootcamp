import { Alchemy, Network } from 'alchemy-sdk';

const settings = {
	apiKey: process.env.NEXT_ALCHEMY_RPC_URL, // Replace with your actual Alchemy API key.
	network: Network.ETH_MAINNET,
};

const alchemy = new Alchemy(settings);

export default alchemy;
