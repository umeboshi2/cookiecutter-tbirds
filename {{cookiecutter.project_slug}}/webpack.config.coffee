path = require 'path'

webpack = require 'webpack'

ManifestPlugin = require 'webpack-manifest-plugin'
StatsPlugin = require 'stats-webpack-plugin'
GoogleFontsPlugin = require 'google-fonts-webpack-plugin'
BundleTracker = require 'webpack-bundle-tracker'

#loaders = require 'tbirds/src/webpack/loaders'
vendor = require 'tbirds/src/webpack/vendor'
resolve = require './webpack-config/resolve'
loaders = require './webpack-config/loaders'


local_build_dir = "{{ local_build_dir }}"

BuildEnvironment = 'dev'
if process.env.PRODUCTION_BUILD
  BuildEnvironment = 'production'
  Clean = require 'clean-webpack-plugin'
  CompressionPlugin = require 'compression-webpack-plugin'
  ChunkManifestPlugin = require 'chunk-manifest-webpack-plugin'
  # FIXME this is only needed until uglify can parse es6
  # coffee-loader is always top
  cl = loaders[0]
  cl.options = transpile: presets: ['env']
  console.log "==============PRODUCTION BUILD=============="
  
WebPackOutputFilename =
  dev: '[name].js'
  production: '[name]-[chunkhash].js'

localBuildDir =
  dev: "{{ dev_build_dir }}"
  production: "{{ local_build_dir }}"

publicPath = localBuildDir[BuildEnvironment] + '/'
if BuildEnvironment is 'dev'
  publicPath = "http://{{ devserver_host }}:{{ devserver_port }}/#{publicPath}"
WebPackOutput =
  filename: WebPackOutputFilename[BuildEnvironment]
  path: path.join __dirname, localBuildDir[BuildEnvironment]
  publicPath: publicPath
    
DefinePluginOpts =
  dev:
    __DEV__: 'true'
    DEBUG: JSON.stringify(JSON.parse(process.env.DEBUG || 'false'))
  production:
    __DEV__: 'false'
    DEBUG: 'false'
    'process.env':
      'NODE_ENV': JSON.stringify 'production'
    
StatsPluginFilename =
  dev: 'stats-dev.json'
  production: 'stats.json'

common_plugins = [
  new webpack.DefinePlugin DefinePluginOpts[BuildEnvironment]
  # FIXME common chunk names in reverse order
  # https://github.com/webpack/webpack/issues/1016#issuecomment-182093533
  new webpack.optimize.CommonsChunkPlugin
    names: ['common', 'vendor']
    filename: WebPackOutputFilename[BuildEnvironment]
  new webpack.optimize.AggressiveMergingPlugin()
  new StatsPlugin StatsPluginFilename[BuildEnvironment], chunkModules: true
  new ManifestPlugin()
  # This is to ignore moment locales with fullcalendar
  # https://github.com/moment/moment/issues/2416#issuecomment-111713308
  new webpack.IgnorePlugin /^\.\/locale$/, /moment$/
  # google fonts
  #new GoogleFontsPlugin
  #  fonts: [
  #    {family: 'Play'}
  #    {family: 'Rambla'}
  #    {family: 'Architects Daughter'}
  #    {family: 'Source Sans Pro'}
  #    ]
  new BundleTracker
    filename: "./#{localBuildDir[BuildEnvironment]}/bundle-stats.json"

  ]

if BuildEnvironment is 'dev'
  dev_only_plugins = []
  AllPlugins = common_plugins.concat dev_only_plugins
else if BuildEnvironment is 'production'
  prod_only_plugins = [
    # production only plugins below
    new webpack.HashedModuleIdsPlugin()
    new webpack.optimize.UglifyJsPlugin
      compress:
        warnings: true
    # FIXME restore CompressionPlugin!!!!!
    #new CompressionPlugin()
    #new ChunkManifestPlugin
    #  filename: 'chunk-manifest.json'
    #  manifestVariable: 'webpackManifest'
    new Clean local_build_dir
    ]
  AllPlugins = common_plugins.concat prod_only_plugins
else
  console.error "Bad BuildEnvironment", BuildEnvironment
  


WebPackConfig =
  entry:
    vendor: vendor
    admin: './client/entries/admin.coffee'
    index: './client/entries/index.coffee'
  output: WebPackOutput
  plugins: AllPlugins
  module:
    loaders: loaders
  resolve: resolve

if BuildEnvironment is 'dev'
  WebPackConfig.devtool = 'source-map'
  WebPackConfig.devServer =
    host: '{{ devserver_host }}'
    port: {{ devserver_port }}
    historyApiFallback: true
    stats:
      colors: true
      modules: false
      chunks: true
      maxModules: 9999
      #reasons: true
      
module.exports = WebPackConfig