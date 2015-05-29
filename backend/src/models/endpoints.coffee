Promise = require 'bluebird'
moment = require 'moment'
_ = require 'lodash'

app = null
client = null
measurements = null
utility = null
self = exports

############################################

self.name = 'models/endpoints'

self.attach = (opts) ->
  app = this

self.init = (done) ->
  client = app.plugins['device-server/client'].client
  measurements = app.plugins['models/measurements']
  utility = app.plugins['utility']
  done()

self.listAll = ->
  Promise.all [@listInDatabase(), @listOnline()]
  .then (results) ->
    _(results).flatten().uniq().compact().value()

self.listInDatabase = ->
  measurements.getEndpointsInDatabaseAsync()

self.listOnline = ->
  client.endpoints().then (data) ->
    eps = []
    eps.push ep.name for ep in data

    eps

self.getMode = (ep) ->
  client.resource ep, 'mode', 'GET'
  .then (res) ->
    parseInt res

self.setColor = (ep, rgba) ->
  client.resource ep, 'led_color', 'PUT', null, utility.rgbaToDecColor(rgba)
