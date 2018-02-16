# inspired by https://github.com/KyleAMathews/coffee-react-quickstart
fs = require 'fs'
path = require 'path'

gulp = require 'gulp'
gutil = require 'gulp-util'
size = require 'gulp-size'
nodemon = require 'gulp-nodemon'
sourcemaps = require 'gulp-sourcemaps'
minimist = require 'minimist'
shell = require 'shelljs'

coffee = require 'gulp-coffee'
#runSequence = require 'run-sequence'
#concat = require 'gulp-concat'
#uglify = require 'gulp-uglify'
{ make_page_html } = require './make-index'

webpack = require 'webpack'

DevServer = require 'webpack-dev-server'

gulp.task 'webpack:coffee', (callback) ->
  DevConfig = require './webpack.config'
  devCompiler = webpack DevConfig  # run webpack
  devCompiler.run (err, stats) ->
    throw new gutil.PluginError('webpack:coffee', err) if err
    gutil.log "[webpack:coffee]", stats.toString(colors: true)
    callback()
    return
  return
  


gulp.task 'webpack:build-prod', (callback) ->
  statopts =
    colors: true
    chunks: true
    modules: false
    #reasons: true
    maxModules: 9999
  # run webpack
  process.env.PRODUCTION_BUILD = 'true'
  process.env.NODE_ENV = 'production'
  ProdConfig = require './webpack.config'
  prodCompiler = webpack ProdConfig
  prodCompiler.run (err, stats) ->
    throw new gutil.PluginError('webpack:build-prod', err) if err
    gutil.log "[webpack:build-prod]", stats.toString statopts
    callback()
    return
  return

#gulp.task 'indexhtml', ['webpack:build-prod'], (callback) ->
gulp.task 'indexhtml', (callback) ->
  process.env.PRODUCTION_BUILD = 'true'
  page = make_page_html 'index'
  fs.writeFileSync 'index.html', page
  console.log "Created new index.html"

gulp.task 'indexdev', (callback) ->
  process.env.NODE_ENV = 'development'
  page = make_page_html 'index'
  fs.writeFileSync 'index-dev.html', page
  console.log "Created new index.html"
  
gulp.task 'default',['indexdev'],->
  gulp.start 'webpack:coffee'
  
gulp.task 'production', ->
  gulp.start 'webpack:build-prod'

gulp.task 'watch', ['webpack:coffee'], ->
  gulp.watch ['./client/**/*.coffee'], ['webpack:coffee']
