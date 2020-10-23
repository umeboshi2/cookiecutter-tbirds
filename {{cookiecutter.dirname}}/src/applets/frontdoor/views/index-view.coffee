import { View } from 'backbone.marionette'
import tc from 'teacup'
import marked from 'marked'

    
class MainView extends View
  template: tc.renderable ->
    tc.div '.row.listview-list-entry', ->
      tc.raw marked '# Hello World!!'

export default MainView

