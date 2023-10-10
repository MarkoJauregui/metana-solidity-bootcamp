import React from 'react';
import ReactDOM from 'react-dom';
import App from './App';
import { Web3ProviderComponent } from '../src/contexts/Web3Context';
import './index.css';

ReactDOM.render(
	<React.StrictMode>
		<Web3ProviderComponent>
			<App />
		</Web3ProviderComponent>
	</React.StrictMode>,
	document.getElementById('root')
);
