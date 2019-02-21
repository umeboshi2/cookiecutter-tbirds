import Backbone from 'backbone'
import Marionette from 'backbone.marionette'
import AppRouter from 'marionette.approuter'
import TkApplet from 'tbirds/tkapplet'

import Controller from './controller'

MainChannel = Backbone.Radio.channel 'global'

class Router extends AppRouter
  appRoutes:
    # handle empty route
    '': 'view_index'
    'frontdoor': 'view_index'
    
class Applet extends TkApplet
  Controller: Controller
  Router: Router

export default Applet
