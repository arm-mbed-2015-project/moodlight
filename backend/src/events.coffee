cfg = require '../config'
app = null

############################################

exports.name = 'events'

exports.attach = (opts) ->
  app = this

exports.init = (done) ->
  express = app.plugins['express']
  client = app.plugins['device-server/client'].client

  express.app.put '/events', (req, res) ->
    app.emit 'events::notification', req.body
    res.status(200).send(null)

  app.on 'express::listening', (server) ->
    client.setPushUrl "http://127.0.0.1:#{cfg.backend.port}/events"
    .then ->
      console.log 'Push URL set.'
      client.preSubscribe [
        'endpoint-type': 'moodlight'
      ]
    .then ->
      console.log 'Pre-subscription set.'
      done()
    
    .catch (err) ->
      console.log 'could not connect to device server'
      done err
