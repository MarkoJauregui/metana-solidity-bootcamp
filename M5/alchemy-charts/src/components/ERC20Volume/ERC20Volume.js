import React, { useEffect, useState } from 'react';
import dynamic from 'next/dynamic';
import alchemy from '../../utils/alchemy';

const DAI_CONTRACT_ADDRESS = '0x6B175474E89094C44Da98b954EedeAC495271d0F';
const Chart = dynamic(() => import('react-apexcharts'), { ssr: false });

const ERC20Volume = () => {
	const [transfers, setTransfers] = useState([]);
	const [isLoading, setIsLoading] = useState(true);

	const getLast10Transfers = async () => {
		let transfersToFetch = 10;
		let fetchedTransfers = [];
		let pageKey;

		while (transfersToFetch > 0) {
			const response = await alchemy.core.getAssetTransfers({
				fromBlock: '0x0',
				toBlock: 'latest',
				contractAddresses: [DAI_CONTRACT_ADDRESS],
				excludeZeroValue: true,
				category: ['erc20'],
				maxCount: '0x3e8', // 1000 in hex
				pageKey,
			});

			fetchedTransfers = [...fetchedTransfers, ...response.transfers];
			pageKey = response.pageKey;

			if (!pageKey || fetchedTransfers.length >= 10) {
				break;
			}
		}

		// Take the last 10 transfers
		return fetchedTransfers.slice(-10);
	};

	useEffect(() => {
		(async () => {
			try {
				const fetchedTransfers = await getLast10Transfers();
				setTransfers(fetchedTransfers);
			} catch (error) {
				console.error('Error fetching DAI transfers:', error);
			} finally {
				setIsLoading(false);
			}
		})();
	}, []);

	const options = {
		chart: {
			id: 'basic-bar',
			toolbar: {
				show: false,
			},
		},
		colors: ['#9F7AEA'], // Purple color
		xaxis: {
			categories: transfers.map((t) => t.blockNum),
			labels: {
				style: {
					fontSize: '12px',
				},
			},
		},
		yaxis: {
			labels: {
				style: {
					fontSize: '12px',
				},
			},
		},
		dataLabels: {
			enabled: false,
		},
	};

	const series = [
		{
			name: 'DAI Transfers',
			data: transfers.map((t) => parseFloat(t.value)),
		},
	];

	return (
		<div className="flex justify-center items-center min-h-screen bg-gray-100">
			<div className="w-full md:w-3/4 lg:w-2/3 xl:w-1/2 p-4 shadow-md bg-white rounded">
				{isLoading ? (
					<div>Loading...</div>
				) : (
					<Chart
						options={options}
						series={series}
						type="bar"
						width="100%"
						height="400"
					/>
				)}
			</div>
		</div>
	);
};

export default ERC20Volume;
