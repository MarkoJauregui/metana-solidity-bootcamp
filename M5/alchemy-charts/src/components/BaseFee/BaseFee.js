import React, { useEffect, useState } from 'react';
import dynamic from 'next/dynamic';
import alchemy from '../../utils/alchemy';

const Chart = dynamic(() => import('react-apexcharts'), { ssr: false });

const BaseFeeChart = () => {
	const [baseFees, setBaseFees] = useState([]);
	const [isLoading, setIsLoading] = useState(true);

	const getLast10BaseFees = async () => {
		const latestBlock = await alchemy.core.getBlockNumber();
		const blocksToFetch = Array.from({ length: 10 }, (_, i) => latestBlock - i);
		const fetchedBaseFees = await Promise.all(
			blocksToFetch.map(async (blockNum) => {
				const blockDetails = await alchemy.core.getBlockWithTransactions(
					blockNum
				);
				return {
					blockNum,
					baseFee: blockDetails.baseFeePerGas,
				};
			})
		);

		return fetchedBaseFees;
	};

	useEffect(() => {
		(async () => {
			try {
				const fetchedBaseFees = await getLast10BaseFees();
				setBaseFees(fetchedBaseFees);
			} catch (error) {
				console.error('Error fetching base fees:', error);
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
			categories: baseFees.map((t) => t.blockNum),
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
			name: 'Base Fees',
			data: baseFees.map((t) => parseFloat(t.baseFee)),
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

export default BaseFeeChart;
