import React from 'react';
import './App.css';
import { ethers } from 'ethers';

const provider = new ethers.providers.JsonRpcProvider(
	process.env.REACT_APP_ALCHEMY_API_KEY
);

function App() {
	return (
		<div className="App bg-gray-100 min-h-screen">
			<header className="App-header bg-blue-500 text-white p-6">
				<h1>Alchemy Charts</h1>
			</header>
		</div>
	);
}

export default App;
