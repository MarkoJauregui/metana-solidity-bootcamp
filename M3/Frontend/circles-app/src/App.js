import React, { useContext } from 'react';
import { Web3Context } from './contexts/Web3Context';
import UserInfo from './components/UserInfo/UserInfo';
import Mint from './components/Mint/Mint';
import Forge from './components/Forge/Forge';
import Trade from './components/Trade/Trade';
import ConnectButton from './components/ConnectButton/ConnectButton';

function App() {
	const { connectWallet, address } = useContext(Web3Context);

	return (
		<div className="container mx-auto my-4 px-4">
			<ConnectButton />
			<div className="my-6 p-4 border rounded shadow-md bg-white max-w-lg mx-auto">
				<UserInfo />
			</div>
			<div className="my-6 p-4 border rounded shadow-md bg-white max-w-lg mx-auto">
				<Mint />
			</div>
			<div className="my-6 p-4 border rounded shadow-md bg-white max-w-lg mx-auto">
				<Forge />
			</div>

			<div className="my-6 p-4 border rounded shadow-md bg-white max-w-lg mx-auto">
				<Trade />
			</div>
		</div>
	);
}

export default App;
