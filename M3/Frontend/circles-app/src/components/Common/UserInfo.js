import React from 'react';
import { useWeb3 } from '../../contexts/Web3Context';

function UserInfo() {
	const { account } = useWeb3();

	return (
		<div>
			<p>Connected Address: {account ? account : 'Not Connected'}</p>
		</div>
	);
}

export default UserInfo;
