Promise = require 'bluebird'

app = null
asyncResponses = null
utility = null

pending = {}

############################################

exports.name = 'device-server/requests'

exports.attach = (options) ->
  app = this

exports.init = (done) ->
  asyncResponses = app.plugins['models/async-responses']
  utility = app.plugins['utility']
  
  app.on 'events::notification', onNotification
  done()

exports.add = (asyncResponseId, callback) ->
  pending[asyncResponseId] = callback

  asyncResponses.findAsync asyncResponseId
  .then (res) ->
    if res
      delete pending[asyncResponseId]
      respond res.data, callback

exports.addAsync = Promise.promisify exports.add

############################################

onNotification = (data) ->
  return unless data and data['async-responses']

  for response in data['async-responses']
    if callback = pending[response.id]
      delete pending[response.id]
      respond response, callback

    else
      asyncResponses.saveAsync response.id, response

respond = (response, callback) ->
  if response.status < 200 or response.status >= 400
    err = new Error response.error
    err.status = response.status
    callback err
  
  else
    decrypted = utility.decryptBase64(response.payload)
    callback null, decrypted

