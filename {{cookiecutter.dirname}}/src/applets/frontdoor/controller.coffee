import Backbone from 'backbone'
import Marionette from 'backbone.marionette'
import tc from 'teacup'
import ms from 'ms'

import ToolbarView from 'tbirds/views/button-toolbar'
import { MainController } from 'tbirds/controllers'
import { ToolbarAppletLayout } from 'tbirds/views/layout'
navigate_to_url = require 'tbirds/util/navigate-to-url'
import scroll_top_fast from 'tbirds/util/scroll-top-fast'

MainChannel = Backbone.Radio.channel 'global'
MessageChannel = Backbone.Radio.channel 'messages'
ResourceChannel = Backbone.Radio.channel 'resources'
AppChannel = Backbone.Radio.channel 'todos'

toolbarEntries = []

toolbarEntryCollection = new Backbone.Collection toolbarEntries
AppChannel.reply 'get-toolbar-entries', ->
  toolbarEntryCollection

class Controller extends MainController
  layoutClass: ToolbarAppletLayout
  setupLayoutIfNeeded: ->
    super()
    toolbar = new ToolbarView
      collection: toolbarEntryCollection
    @layout.showChildView 'toolbar', toolbar
    return
    
  start: ->
    @view_index()
    
  view_index: ->
    @setupLayoutIfNeeded()
    # https://jsperf.com/bool-to-int-many
    completed = completed ^ 0
    require.ensure [], () =>
      View = require './views/index-view.coffee'
      view = new View
      @layout.showChildView 'content', view
    # name the chunk
    , 'frontdoor-view-index'
      
export default Controller

