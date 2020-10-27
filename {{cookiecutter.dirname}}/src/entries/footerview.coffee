import { Radio, Model } from 'backbone'
import { View } from 'backbone.marionette'
import tc from 'teacup'
import ms from 'ms'

import  './base'
import MainAappConfig from './index-config'

MainChannel = Radio.channel 'global'
MessageChannel = Radio.channel 'messages'

class FooterView extends View
  template: tc.renderable (model) ->
    version_style = '.col-md-2.col-md-offset-10'
    timestyle = '.col-md-2.col-md-offset-1'
    tc.div '.col-md-10.col-md-offset-1', ->
      tc.table '.table', ->
        tc.tr ->
          tc.td "Some message here"
          tc.td "Version: #{model.version}"
  
  
export default FooterView



