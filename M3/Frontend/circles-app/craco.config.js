module.exports = {
	webpack: {
		configure: (webpackConfig) => {
			webpackConfig.resolve.fallback = {
				...webpackConfig.resolve.fallback, // Spread the previous fallbacks
				http: require.resolve('stream-http'),
				https: require.resolve('https-browserify'),
				os: require.resolve('os-browserify/browser'),
				stream: require.resolve('stream-browserify'), // Add the stream polyfill here
				assert: require.resolve('assert'), // Just to be sure, let's keep the assert polyfill too
				buffer: require.resolve('buffer/'),
			};
			return webpackConfig;
		},
	},
};
