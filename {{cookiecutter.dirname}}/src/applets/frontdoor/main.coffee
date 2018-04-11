import Backbone from 'backbone'
import Marionette from 'backbone.marionette'
import TkApplet from 'tbirds/tkapplet'

import Controller from './controller'

MainChannel = Backbone.Radio.channel 'global'

class Router extends Marionette.AppRouter
  appRoutes:
    # handle empty route
    '': 'view_index'
    'frontdoor': 'view_index'
    
class Applet extends TkApplet
  Controller: Controller
  Router: Router

export default Applet
