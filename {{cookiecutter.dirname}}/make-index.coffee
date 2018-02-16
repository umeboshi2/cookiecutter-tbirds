beautify = require('js-beautify').html

pages = require './page-templates'

get_manifest = (name) ->
  if process.env.NODE_ENV is 'development'
    manifest =
      'common.js': 'common.js'
      'vendor.js': 'vendor.js'
    filename = "#{name}.js"
    manifest[filename] = filename
    manifest.assetsPath = 'assets/client-dev'
  else
    manifest = require './assets/client/manifest.json'
    manifest.assetsPath = 'assets/client'
  return manifest


create_page_html = (name, manifest, theme, clients) ->
  page = pages[name] manifest, theme, clients
  beautify page

make_page_html = (name) ->
  # FIXME make a site config
  theme = 'vanilla'
  manifest = get_manifest name
  page = create_page_html name, manifest, theme
  return page

module.exports =
  make_page_html: make_page_html
  templates: pages
  
