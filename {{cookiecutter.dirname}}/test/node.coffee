import chai from 'chai'
import sinon from 'sinon'
import sinonChai from 'sinon-chai'
import chaiJq from 'chai-jq'

chai.use sinonChai
chai.use chaiJq

global.chai = chai
global.sinon = sinon

if not global?.document or not global?.window
  jsdom = require('jsdom').jsdom
  _html = '<html><head><script></script></head><body></body></html>'
  global.document = jsdom _html,
    FetchExternalResources: ['script'],
    ProcessExternalResources: ['script']
  global.window = document.defaultView
  global.navigator = global.window.navigator
  global.foo = 'bar baa bar bar'
  
require('./setup')()
