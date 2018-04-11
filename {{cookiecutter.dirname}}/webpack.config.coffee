path = require 'path'

webpack = require 'webpack'

ManifestPlugin = require 'webpack-manifest-plugin'
StatsPlugin = require 'stats-webpack-plugin'
BundleTracker = require 'webpack-bundle-tracker'
MiniCssExtractPlugin = require 'mini-css-extract-plugin'


BuildEnvironment = process.env.NODE_ENV or 'development'

localBuildDir =
  development: "dist"
  production: "dist"

outputFilename = (ext) ->
  d = "[name].#{ext}"
  p = "[name]-[chunkhash].#{ext}"
  return
    development: d
    production: p
    

WebPackOutputFilename = outputFilename 'js'
CssOutputFilename = outputFilename 'css'


publicPath = localBuildDir[BuildEnvironment]
if not publicPath.endsWith '/'
  publicPath = "#{publicPath}/"
  
WebPackOutput =
  filename: WebPackOutputFilename[BuildEnvironment]
  path: path.join __dirname, localBuildDir[BuildEnvironment]
  publicPath: localBuildDir[BuildEnvironment]
  
DefinePluginOpts =
  development:
    __DEV__: 'true'
    DEBUG: JSON.stringify(JSON.parse(process.env.DEBUG || 'false'))
    #__useCssModules__: 'true'
    __useCssModules__: 'false'
  production:
    __DEV__: 'false'
    DEBUG: 'false'
    __useCssModules__: 'true'
    'process.env':
      'NODE_ENV': JSON.stringify 'production'
    
StatsPluginFilename =
  development: 'stats-dev.json'
  production: 'stats.json'

coffeeLoaderRule =
  test: /\.coffee$/
  use: ['coffee-loader']

ExtractedCssFilename = (filename) ->
  name = "#{filename}.css"
  if BuildEnvironment is 'production'
    name = "#{filename}-[chunkhash].css"
  return name
  

loadCssRule =
  test: /\.css$/
  use: ['style-loader', 'css-loader']

sassOptions =
  includePaths: [
    'node_modules/compass-mixins/lib'
    'node_modules/bootstrap/scss'
  ]
    
loadScssRule =
  test: /\.scss$/
  use: [
    {
      loader: 'style-loader'
    },{
      loader: 'css-loader'
    },{
      loader: 'sass-loader'
      options: sassOptions
    }
  ]


devCssLoader = [
  {
    loader: 'style-loader'
  },{
    loader: 'css-loader'
  },{
    loader: 'sass-loader'
    options: sassOptions
  }
]


miniCssLoader =
  [
    MiniCssExtractPlugin.loader
    {
      loader: 'css-loader'
      options:
        minimize:
          safe: true
    #},{
    #  loader: 'postcss-loader'
    #  options:
    #    autoprefixer:
    #      browsers: ["last 2 versions"]
    #    plugins: () =>
    #      [ autoprefixer ]
    },{
      loader: "sass-loader"
      options: sassOptions
    }
  ]


buildCssLoader =
  development: devCssLoader
  production: miniCssLoader

common_plugins = [
  new webpack.DefinePlugin DefinePluginOpts[BuildEnvironment]
  # FIXME common chunk names in reverse order
  # https://github.com/webpack/webpack/issues/1016#issuecomment-182093533
  new StatsPlugin StatsPluginFilename[BuildEnvironment], chunkModules: true
  new ManifestPlugin()
  new BundleTracker
    filename: "./#{localBuildDir[BuildEnvironment]}/bundle-stats.json"
  # This is to ignore moment locales with fullcalendar
  # https://github.com/moment/moment/issues/2416#issuecomment-111713308
  new webpack.IgnorePlugin /^\.\/locale$/, /moment$/
  new MiniCssExtractPlugin
    filename: CssOutputFilename[BuildEnvironment]
  ]

extraPlugins = []
if BuildEnvironment is 'production'
  CleanPlugin = require 'clean-webpack-plugin'
  CompressionPlugin = require 'compression-webpack-plugin'
  UglifyJsPlugin = require('uglifyjs-webpack-plugin')
  OptimizeCssAssetsPlugin = require 'optimize-css-assets-webpack-plugin'
  extraPlugins.push new CompressionPlugin()
  #extraPlugins.push new UglifyJsPlugin()
  #extraPlugins.push new OptimizeCssAssetsPlugin()
  

AllPlugins = common_plugins.concat extraPlugins



WebPackOptimization =
  splitChunks:
    chunks: 'async'
    cacheGroups:
      vendor:
        chunks: "initial"
        name: "vendor"
        enforce: true
      common:
        chunks: "initial"
        minChunks: 3
        name: "common"
        enforce: true

if BuildEnvironment is 'production'
  WebPackOptimization.minimizer = [
    new OptimizeCssAssetsPlugin()
    new UglifyJsPlugin()
    ]
WebPackConfig =
  mode: BuildEnvironment
  optimization: WebPackOptimization
  entry:
    index: './src/entries/index.coffee'
  output: WebPackOutput
  plugins: AllPlugins
  module:
    rules: [
      loadCssRule
      {
        test: /\.scss$/
        use: buildCssLoader[BuildEnvironment]
      },{
        test: /NONONOtbirds\/src\/sass\/cornsilk\.scss$/
        use: miniCssLoader
      }
      coffeeLoaderRule
      {
        test: /\.woff(2)?(\?v=[0-9]\.[0-9]\.[0-9])?$/
        use: [
          {
            loader: 'url-loader'
            options:
              limit: 10000
              mimetype: "application/font-woff"
              name: "[path][name].[ext]?[hash]"
          }
        ]
      }
      {
        test: /\.(gif|png|eot|ttf)?$/
        use: [
          {
            loader: 'file-loader'
            options:
              limit: undefined
          }
        ]
      }
      {
        test: /\.(ttf|eot|svg)(\?v=[0-9]\.[0-9]\.[0-9])?$/
        use: [
          {
            loader: 'file-loader'
            options:
              limit: undefined
          }
        ]
      }
    ]
  resolve:
    extensions: [".wasm", ".mjs", ".js", ".json", ".coffee"]
    alias:
      applets: path.join __dirname, 'src/applets'
      sass: path.join __dirname, 'sass'
      compass: "node_modules/compass-mixins/lib/compass"
      #tbirds: 'tbirds/dist'
      tbirds: 'tbirds/src'
      #tsass: 'node_modules/tbirds/sass'
      # https://github.com/wycats/handlebars.js/issues/953
      handlebars: 'handlebars/dist/handlebars'
  stats:
    colors: true
    modules: false
    chunks: true
    #maxModules: 9999
    #reasons: true


if BuildEnvironment is 'development'
  WebPackConfig.devtool = 'source-map'
  WebPackConfig.devServer =
    host: '{{ cookiecutter.devserver_host }}'
    port: {{ cookiecutter.devserver_port }}
    historyApiFallback: true
    # cors for using a server on another port
    headers: {"Access-Control-Allow-Origin": "*"}
    stats:
      colors: true
      modules: false
      chunks: true
      #maxModules: 9999
      #reasons: true
      
module.exports = WebPackConfig
