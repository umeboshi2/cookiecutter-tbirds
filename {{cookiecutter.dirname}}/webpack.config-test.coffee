path = require 'path'
webpack = require 'webpack'
srcdir = path.join __dirname, 'src'
testdir = path.join __dirname, 'test'
buildCssLoader = require 'tbirds/webpack-config/sass-loader-chain'

coffeeLoaderTranspileRule =
  test: /\.coffee$/
  loader: 'coffee-loader'
  options:
    transpile:
      presets: ['@babel/env']
      #presets: ['env']
      #plugins: ["dynamic-import-webpack"]
    sourceMap: true

coffeeLoaderBasicRule =
  test: /\.coffee$/
  loader: 'coffee-loader'
  options:
    sourceMap: true

loadCssRule =
  test: /\.css$/
  use: ['style-loader', 'css-loader']

scssRule =
  test: /\.scss$/
  use: buildCssLoader.development

DefinePluginOpts =
  development:
    __DEV__: 'true'
    DEBUG: JSON.stringify(JSON.parse(process.env.DEBUG || 'false'))
    #__useCssModules__: 'true'
    __useCssModules__: 'false'

definePlugin = new webpack.DefinePlugin DefinePluginOpts.development
    
module.exports =
  target: 'node'
  mode: 'development'
  module:
    rules: [
      coffeeLoaderBasicRule
      loadCssRule
      scssRule
    ]
  resolve:
    extensions: [".wasm", ".mjs", ".js", ".json", ".coffee"]
    alias:
      tbirds: 'tbirds/dist'
      applets: path.join testdir, 'applets'
  plugins: [ definePlugin ]
  
      
