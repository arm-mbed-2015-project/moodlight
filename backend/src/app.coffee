util = require 'util'

require 'coffee-errors'
broadway = require 'broadway'
cfg = require '../config'

app = new broadway.App()

app.use require('./utility')
app.use require('./database/mongo')
app.use require('./database/aggregation')
app.use require('./models/async-responses')
app.use require('./models/endpoints')
app.use require('./models/settings')
app.use require('./models/measurements')
app.use require('./express'), port: cfg.backend.port
app.use require('./socketio')
app.use require('./events')
app.use require('./ext-weather')
app.use require('./ext-weather-updater')
app.use require('./device-server/client'), port: cfg.deviceServer.port
app.use require('./device-server/requests')
app.use require('./rest-api/stats')
app.use require('./rest-api/endpoints')
app.use require('./rest-api/resources')
app.use require('./rest-api/settings')

app.on 'mongo::initialized', ->
  console.log 'MongoDB initialized'

app.on 'events::notification', (json) ->
  console.log @event
  console.log util.inspect(json, depth: null)
  console.log ''

app.init (err) ->
  if err
    console.error err
    process.exit()

  console.log 'Initialized.'
