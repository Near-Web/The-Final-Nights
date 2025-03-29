/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

const createBabelConfig = options => {
  const { presets = [], plugins = [], removeConsole } = options;
  return {
    presets: [
      ['@babel/preset-env', {
        modules: 'commonjs',
        useBuiltIns: 'entry',
        corejs: '3',
        spec: false,
        loose: true,
        targets: [],
      }],
      ...presets,
    ].filter(Boolean),
    plugins: [
      '@babel/plugin-transform-jscript',
      'babel-plugin-inferno',
      removeConsole && require.resolve('babel-plugin-transform-remove-console'),
      'common/string.babel-plugin.cjs',
      ...plugins,
    ].filter(Boolean),
  };
};

module.exports = (api) => {
  api.cache(true);
  const mode = process.env.NODE_ENV;
  return createBabelConfig({ mode });
};

module.exports.createBabelConfig = createBabelConfig;
