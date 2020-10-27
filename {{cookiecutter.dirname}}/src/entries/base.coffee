import $ from 'jquery'
import _ from 'lodash'
import { Radio, Model } from 'backbone'
import { View } from 'backbone.marionette'

import 'bootstrap'
import 'font-awesome/scss/font-awesome.scss'
# FIXME need better way to resolve tbirds sass
import  '../../node_modules/tbirds/sass/dark.scss'

if __DEV__
  console.warn "__DEV__", __DEV__, "DEBUG", DEBUG
  Radio.DEBUG = true

import IsEscapeModal from 'tbirds/behaviors/is-escape-modal'

MainChannel = Radio.channel 'global'
MessageChannel = Radio.channel 'messages'

if __DEV__
  require '../inspector'
  
class BaseModalView extends View
  behaviors: [IsEscapeModal]
  ui:
    close_btn: '#close-modal div'
    
MainChannel.reply 'main:app:BaseModalView', ->
  BaseModalView
  
show_modal = (view, backdrop=false) ->
  app = MainChannel.request 'main:app:object'
  modal_region = app.getView().getRegion 'modal'
  modal_region.backdrop = backdrop
  modal_region.show view

MainChannel.reply 'show-modal', (view, backdrop=false) ->
  console.warn 'show-modal', backdrop
  show_modal view, false

currentUser = new Model
  isGuest: true
  name: 'Guest'
  fullname: 'Guest User'
  groups: []
    
MainChannel.reply 'main:app:currentUser', ->
  return currentUser

