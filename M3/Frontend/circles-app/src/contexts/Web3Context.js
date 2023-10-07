import { createContext, useContext, useState, useEffect } from 'react';
import { Web3Provider as EthersWeb3Provider } from '@ethersproject/providers';

// Create Context
const Web3Context = createContext();

export const Web3Provider = ({ children }) => {
	const [provider, setProvider] = useState(null);
	const [signer, setSigner] = useState(null);
	const [account, setAccount] = useState(null);

	// Connect to MetaMask on mount
	useEffect(() => {
		if (window.ethereum) {
			const web3Provider = new EthersWeb3Provider(window.ethereum);
			setProvider(web3Provider);
			const signerInstance = web3Provider.getSigner();
			setSigner(signerInstance);
			signerInstance.getAddress().then(setAccount);
		}
	}, []);

	return (
		<Web3Context.Provider value={{ provider, signer, account }}>
			{children}
		</Web3Context.Provider>
	);
};

// Custom hook to use Web3 context
export const useWeb3 = () => {
	const context = useContext(Web3Context);
	if (!context) {
		throw new Error('useWeb3 must be used within a Web3Provider');
	}
	return context;
};

export default Web3Context;
