/* eslint-disable global-require */
/* eslint-disable import/no-extraneous-dependencies */

// based on https://github.com/facebook/metro/blob/3f4f54247211911fe80bab8aaac703c7b2e90fb6/packages/metro-react-native-babel-preset/src/configs/main.js

function isTypeScriptSource(fileName) {
  return !!fileName && fileName.endsWith('.ts');
}

function isTSXSource(fileName) {
  return !!fileName && fileName.endsWith('.tsx');
}

module.exports = function(api) {
  api.cache(true);

  const presets = [require('./preset-env.config')];
  const plugins = [
    // the flow strip types plugin must go BEFORE class properties!
    // there'll be a test case that fails if you don't.
    require('@babel/plugin-transform-flow-strip-types'),
    require('@babel/plugin-transform-react-jsx'),
    [
      require('@babel/plugin-proposal-class-properties'),
      // use `this.foo = bar` instead of `this.defineProperty('foo', ...)`
      { loose: true },
    ],
  ];
  const overrides = [
    {
      test: isTypeScriptSource,
      plugins: [
        [
          require('@babel/plugin-transform-typescript'),
          {
            isTSX: false,
            allowNamespaces: true,
          },
        ],
      ],
    },
    {
      test: isTSXSource,
      plugins: [
        [
          require('@babel/plugin-transform-typescript'),
          {
            isTSX: true,
            allowNamespaces: true,
          },
        ],
      ],
    },
  ];

  const env = process.env.BABEL_ENV || process.env.NODE_ENV;
  if (!env || env === 'development') {
    plugins.push(require('react-refresh/babel'));
  }

  return {
    presets,
    plugins,
    overrides,
  };
};
