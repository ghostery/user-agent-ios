module.exports = {
  resolver: {
    extraNodeModules: {
      fs: require.resolve('./ReactNative/js/_empty'),
      // stream: require.resolve('stream-browserify'),
      // http: require.resolve('stream-http'),
      // https: require.resolve('https-browserify'),
      path: require.resolve('path-browserify'),
      // buffer: require.resolve('buffer'),
    },
  },
};