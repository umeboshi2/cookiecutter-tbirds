import { Radio, Model } from 'backbone'
import Marionette from 'backbone.marionette'
import tc from 'teacup'
import ms from 'ms'

import navigate_to_url from 'tbirds/util/navigate-to-url'
import objectEmpty from 'tbirds/util/object-empty'
import createMainApp from 'tbirds/start-main-app'

import './base'
import FooterView from './footerview'

pkg = require '../../package.json'
pkgmodel = new Model pkg

import MainAppConfig from './index-config'

MainChannel = Radio.channel 'global'
MessageChannel = Radio.channel 'messages'

show_footer = ->
  view = new FooterView
    model: pkgmodel
  footer_region = app.getView().getRegion 'footer'
  footer_region.show view

app = createMainApp MainAppConfig
if __DEV__
  # DEBUG attach app to window
  window.App = app

app.on 'before:start', ->
  if __DEV__ and DEBUG
    console.log "before:start"

app.on 'start', ->
  if __DEV__ and DEBUG
    console.log "app.on start called"
    
app.start
  state:
    currentUser: null
  
export default app


