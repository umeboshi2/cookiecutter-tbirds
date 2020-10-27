import { extend, filter } from 'lodash'
import { Radio, Model } from 'backbone'
import yaml from 'js-yaml'

MainChannel = Radio.channel 'global'

class NoCacheModel extends Model
  fetch: (options) ->
    options = extend options || {},
      data:
        nocache: Date.now()
    super options

class TextModel extends NoCacheModel
  fetch: (options) ->
    options = extend options || {},
      dataType: 'text'
    super options
  

export class StaticDocument extends TextModel
  url: ->
    "/assets/docs/#{@id}.md"
  
  parse: (response) ->
    return content: response

export staticDocument = (name) ->
  return new StaticDocument
    id: name
