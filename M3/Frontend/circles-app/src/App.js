import React from 'react';

import UserInfo from './components/UserInfoComponent/UserInfo';
import Mint from './components/MintComponent/Mint';
import Forge from './components/ForgeComponent/Forge';
import Trade from './components/TradeComponent/Trade';

function App() {
	return (
		<div className="App">
			<header className="App-header">
				<h1>Circles App</h1>
			</header>
			<UserInfo />
			<Mint />
			<Forge />
			<Trade />
		</div>
	);
}

export default App;
