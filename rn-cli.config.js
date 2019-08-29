module.exports = {
  resolver: {
    extraNodeModules: {
      fs: require.resolve('./ReactNative/js/_empty'),
      path: require.resolve('path-browserify'),
    },
  },
};