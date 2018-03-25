$= require 'jquery'
_ = require 'underscore'
Backbone = require 'backbone'
Marionette = require 'backbone.marionette'

require 'bootstrap'

if __DEV__
  console.warn "__DEV__", __DEV__, "DEBUG", DEBUG
  Backbone.Radio.DEBUG = true

require 'tbirds/applet-router'
IsEscapeModal = require 'tbirds/behaviors/is-escape-modal'

MainChannel = Backbone.Radio.channel 'global'
MessageChannel = Backbone.Radio.channel 'messages'

if __DEV__
  require '../inspector'
  
class BaseModalView extends Marionette.View
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
  


module.exports = {}



