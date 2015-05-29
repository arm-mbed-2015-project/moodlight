socketio = require 'socket.io'
_ = require 'lodash'
app = null
io = null
client = null
utility = null

############################################

exports.name = 'socketio'

exports.attach = (opts) ->
  app = this

exports.init = (done) ->
  client = app.plugins['device-server/client'].client
  settings = app.plugins['models/settings']
  utility = app.plugins['utility']

  app.on 'events::notification', (data) ->
    return unless data.notifications

    res = {}
    for n in data.notifications
      res[n.ep] or= {}
      res[n.ep][n.path] = utility.decryptBase64 n.payload

    io?.emit 'notifications', res

  app.on 'express::listening', (server) ->
    io = exports.io = socketio server

    if io
      done()
    else
      done new Error 'failed to start socketio' 
