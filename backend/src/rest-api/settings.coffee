Promise = require 'bluebird'
moment = require 'moment'
_ = require 'lodash'

app = null
express = null
settings = null

self = exports
self.name = 'rest-api/settings'

self.attach = (opts) ->
  app = this

self.init = (done) ->
  express = app.plugins['express']
  settings = app.plugins['models/settings']
  register()
  done()

############################################

register = ->
  express.app.get '/endpoints/:endpoint/settings', (req, res, next) ->
    settings.findAsync req.params.endpoint
    .then (settings) ->
      res.send settings
    .catch (err) ->
      res.status(500).send(err.message).end()

  express.app.put '/endpoints/:endpoint/settings', (req, res, next) ->
    settings.saveAsync req.params.endpoint, req.body
    .then (settings) ->
      app.emit 'settings::cityChanged',
        endpoint: req.params.endpoint
        city: req.body
      res.status(204).end()
    .catch (err) ->
      res.status(500).send(err.message).end()
