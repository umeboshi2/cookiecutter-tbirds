import tc from 'teacup'
import emoji from 'node-emoji'

import ModalRegion from 'tbirds/regions/bsmodal'
import config from 'tbirds/app-config'
import MainPageLayout from 'tbirds/tklayout'

class Layout extends MainPageLayout
  template: tc.renderable () ->
    tc.div '#modal'
    tc.div ".container-fluid", ->
      tc.div '#navbar-view-container'
      tc.div '.row.fixed-bottom', ->
        tc.div '#messages'
      tc.div '#applet-content'
      tc.div '#footer'

  regions:
    messages: '#messages'
    navbar: '#navbar-view-container'
    modal: ModalRegion
    applet: '#applet-content'
    footer: '#footer'
  
navbarBrandTemplate = tc.renderable (model) ->
  padding = '.pt-2.pl-2.pr-2'
  padding = "#{padding}.mb-0.rounded.border.border-secondary"
  src = "/assets/zuki.png"
  tc.a ".navbar-brand.bg-body-d5#{padding}", href:model.url, ->
    tc.img '.mb-2', src:src, style:'width:1.5rem;height:1.5rem'
    tm = emoji.get 'tm'
    tc.span '.mt-2.text-primary', "#{model.label}#{tm}"
  tc.span '.toggle-container'

config.layout = Layout
config.hasUser = false
config.brand.label = '{{cookiecutter.label}}'
config.brand.url = '#'
config.navbarBrandTemplate = navbarBrandTemplate
config.appRegion = '#root-div'
export default config
