Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
tc = require 'teacup'
ms = require 'ms'

navigate_to_url = require 'tbirds/util/navigate-to-url'
TopApp = require 'tbirds/top-app'
objectEmpty = require 'tbirds/util/object-empty'

require './base'
FooterView = require './footerview'

pkg = require '../../package.json'
pkgmodel = new Backbone.Model pkg

MainAppConfig = require './index-config'

MainChannel = Backbone.Radio.channel 'global'
MessageChannel = Backbone.Radio.channel 'messages'

show_footer = ->
  view = new FooterView
    model: pkgmodel
  footer_region = app.getView().getRegion 'footer'
  footer_region.show view

app = new TopApp
  appConfig: MainAppConfig

if __DEV__
  # DEBUG attach app to window
  window.App = app

# register the main router
MainChannel.request 'main:app:route'

app.on 'before:start', ->
  theme = MainChannel.request 'main:app:get-theme'
  theme = if theme then theme else 'vanilla'
  MainChannel.request 'main:app:switch-theme', theme

app.on 'start', ->
  #doSomething = ->
  #  console.log "Doing something"
  #setInterval doSomething, ms, '10s'
  if __DEV__
    console.log "app.on start called"
    
app.start
  state:
    currentUser: null
  
module.exports = app


