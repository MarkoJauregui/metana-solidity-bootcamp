import React from 'react';
import ConnectWalletButton from './components/Common/ConnectWalletButton';
import UserInfo from './components/Common/UserInfo';
import MintTokens from './components/Mint/MintTokens';
import ForgeTokens from './components/Forge/ForgeTokens';
import TradeTokens from './components/Trade/TradeTokens';

function App() {
	return (
		<div className="App">
			<ConnectWalletButton />
			<UserInfo />
			<MintTokens />
			<ForgeTokens />
			<TradeTokens />
		</div>
	);
}

export default App;
