config = require 'tbirds/app-config'

config.hasUser = false
config.brand.label = '{{cookiecutter.label}}'
config.brand.url = '#'

config.authToken = {}
config.authToken.refreshInterval = '5m'
config.authToken.refreshIntervalMultiple = 3
config.authToken.loginUrl = '#frontdoor/login'

config.appRegion = '#root-div'
module.exports = config
