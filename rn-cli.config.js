module.exports = {
  resolver: {
    sourceExts: ['jsx', 'js', 'tsx', 'ts'],
    extraNodeModules: {
      fs: require.resolve('./ReactNative/js/_empty'),
      path: require.resolve('path-browserify'),
    },
  },
};
