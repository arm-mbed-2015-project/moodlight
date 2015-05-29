Promise = require 'bluebird'
moment = require 'moment'
_ = require 'lodash'

app = null
express = null
endpoints = null
self = exports

############################################

self.name = 'rest-api/endpoints'

self.attach = (opts) ->
  app = this

self.init = (done) ->
  express = app.plugins['express']
  endpoints = app.plugins['models/endpoints']
  register()
  done()

############################################

register = ->
  express.app.get '/endpoints', (req, res, next) ->
    endpoints.listAll().then (endpoints) ->
      res.send endpoints
    .catch (err) ->
      res.status(500).send(err.message).end()
