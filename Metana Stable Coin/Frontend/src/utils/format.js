// utils/format.js

/**
 * Formats a number with commas as thousands separators
 * @param {number} number - The number to format.
 * @param {boolean} [noDecimals=false] - Whether to display decimals.
 * @returns {string} - The formatted number as a string.
 */

export const formatNumber = (number, noDecimals = false, decimals = 2) => {
	const options = {
		minimumFractionDigits: noDecimals ? 0 : decimals,
		maximumFractionDigits: noDecimals ? 0 : decimals,
	};
	return Number(number).toLocaleString(undefined, options);
};

/**
 * Formats a number as currency
 * @param {number} amount - The amount to format.
 * @param {string} [currency='USD'] - The currency symbol.
 * @param {number} [decimals=2] - Number of decimal places.
 * @returns {string} - The formatted currency amount.
 */
export const formatCurrency = (amount, currency = 'USD', decimals = 2) => {
	return `${currency} ${formatNumber(amount, decimals === 0)}`;
};
