// utils/format.js

import { ethers } from 'ethers';

export const formatAddress = (address) => {
	return `${address.substring(0, 6)}...${address.substring(
		address.length - 4
	)}`;
};

// Assuming balance is a string representing Ether, not Wei
export const formatBalance = (balance) => {
	// Ensure balance is a number, then format to 2 decimal places
	return Number(balance).toFixed(2);
};
