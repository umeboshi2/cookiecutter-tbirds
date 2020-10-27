module.exports = ->

  setFixtures = ->
    _.each arguments, (content) ->
      $fixtures.append content
      return
    return

  clearFixtures = ->
    $fixtures.empty()
    return

  if process.env.USE_LODASH
    pathScore = require.resolve('underscore')
    pathDash = require.resolve('lodash')
    require pathDash
    require.cache[pathScore] = require.cache[pathDash]
  lib = if process.env.USE_LODASH then 'lodash' else 'underscore'
  _ = require('underscore')
  console.log 'Using ' + lib + ': ' + _.VERSION
  Backbone = require('backbone')
  jQuery = require('jquery')
  Backbone.$ = jQuery
  Marionette = require('backbone.marionette')
  global.$ = global.jQuery = jQuery
  global._ = _
  global.Backbone = Backbone
  global.Marionette = Backbone.Marionette = Marionette
  global.expect = global.chai.expect
  $fixtures = undefined
  before ->
    $fixtures = $('<div id="fixtures">')
    $('body').append $fixtures
    @setFixtures = setFixtures
    @clearFixtures = clearFixtures
    return
  beforeEach ->
    @sinon = global.sinon.createSandbox()
    return
  afterEach ->
    @sinon.restore()
    window.location.hash = ''
    Backbone.history.stop()
    Backbone.history.handlers.length = 0
    clearFixtures()
    return
  return
