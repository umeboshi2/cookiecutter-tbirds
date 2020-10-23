import { Radio } from 'backbone'
import AppRouter from 'tbirds/routers/approuter'
import TkApplet from 'tbirds/tkapplet'

import Controller from './controller'

MainChannel = Radio.channel 'global'

class Router extends AppRouter
  appRoutes:
    # handle empty route
    '': 'view_index'
    'frontdoor': 'view_index'
    
class Applet extends TkApplet
  Controller: Controller
  Router: Router

export default Applet
