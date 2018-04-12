path = require 'path'

webpack = require 'webpack'

ManifestPlugin = require 'webpack-manifest-plugin'
StatsPlugin = require 'stats-webpack-plugin'
BundleTracker = require 'webpack-bundle-tracker'
MiniCssExtractPlugin = require 'mini-css-extract-plugin'
HtmlPlugin = require 'html-webpack-plugin'


BuildEnvironment = process.env.NODE_ENV or 'development'
if BuildEnvironment not in ['development', 'production']
  throw new Error "Undefined environment #{BuildEnvironment}"

# handles output filename for js and css
outputFilename = (ext) ->
  d = "[name].#{ext}"
  p = "[name]-[chunkhash].#{ext}"
  return
    development: d
    production: p
    

# set output filenames
WebPackOutputFilename = outputFilename 'js'
CssOutputFilename = outputFilename 'css'


# path to build directory
localBuildDir =
  development: "dist"
  production: "dist"

# set publicPath
publicPath = localBuildDir[BuildEnvironment]
if not publicPath.endsWith '/'
  publicPath = "#{publicPath}/"
  
WebPackOutput =
  filename: WebPackOutputFilename[BuildEnvironment]
  #path: path.join __dirname, localBuildDir[BuildEnvironment]
  #publicPath: publicPath
  
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

loadCssRule =
  test: /\.css$/
  use: ['style-loader', 'css-loader']

sassOptions =
  includePaths: [
    'node_modules/compass-mixins/lib'
    'node_modules/bootstrap/scss'
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
  new HtmlPlugin
    template: './index.coffee'
  ]
    

extraPlugins = []

WebPackOptimization =
  splitChunks:
    chunks: 'all'

if BuildEnvironment is 'production'
  CleanPlugin = require 'clean-webpack-plugin'
  CompressionPlugin = require 'compression-webpack-plugin'
  UglifyJsPlugin = require 'uglifyjs-webpack-plugin'
  OptimizeCssAssetsPlugin = require 'optimize-css-assets-webpack-plugin'
  extraPlugins.push new CleanPlugin(localBuildDir[BuildEnvironment])
  extraPlugins.push new CompressionPlugin()
  WebPackOptimization.minimizer = [
    new OptimizeCssAssetsPlugin()
    new UglifyJsPlugin()
    ]
  


AllPlugins = common_plugins.concat extraPlugins


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
      # FIXME combine next two rules
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
      tbirds: 'tbirds/src'
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
