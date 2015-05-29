util = require 'util'
Promise = require 'bluebird'
_ = require 'lodash'

app = null
weather = null
utility = null
self = exports

############################################

self.name = 'ext-weather-updater'

self.attach = (opts) ->
  app = this
  self.intervalSeconds = opts.intervalSeconds or 300

self.init = (done) ->
  weather = app.plugins['ext-weather']
  utility = app.plugins['utility']
  app.on 'resources::modeChanged', modeOrCityChanged
  app.on 'settings::cityChanged', modeOrCityChanged
  startTimer()
  done()

############################################

modeOrCityChanged = (data) ->
  if weather.isWeatherMode data.mode
    weather.updateOnce [data.endpoint]

startTimer = ->
  setTimeout updateLoop, self.intervalSeconds * 1000

updateLoop = ->
  weather.updateOnce []
  .then ->
    startTimer()
  .catch (err) ->
    console.log 'weather update failed', util.inspect(err, depth: null)
