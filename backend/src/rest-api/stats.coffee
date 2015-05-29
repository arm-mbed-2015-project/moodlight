Promise = require 'bluebird'
moment = require 'moment'
_ = require 'lodash'

app = null
express = null
mongo = null
measurements = null

self = exports
self.name = 'rest-api/stats'

self.attach = (opts) ->
  app = this

self.init = (done) ->
  express = app.plugins['express']
  mongo = app.plugins['database/mongo']
  measurements = app.plugins['models/measurements']
  app.on 'mongo::initialized', register
  done()

############################################

register = ->
  registerAll()
  registerAggregated agg for agg in ['30s', '5m', 'hourly', 'daily']

registerAll = ->
  express.app.get '/endpoints/:endpoint/stats/all', (req, res, next) ->
    return unless isValidRequest req, res

    from = moment.utc(req.query.from)
    to = moment.utc(req.query.to)

    query = 
      _id: 
        $gte: mongo.objectIdFromDate from.toDate()
        $lt: mongo.objectIdFromDate to.toDate()
      ep: req.params.endpoint
      path: 
        $in: req.query.resources

    measurements.findAsync query
    .then (data) ->
      res.send formatData(data)
    .catch (err) ->
      res.status(500).send(err.message).end()

registerAggregated = (agg) ->
  express.app.get "/endpoints/:endpoint/stats/#{agg}", (req, res, next) ->
    return unless isValidRequest req, res

    from = moment.utc(req.query.from).millisecond(0).second(0)
    to = moment.utc(req.query.to)

    if agg is '5m'
      from.minutes(from.minutes() - from.minutes() % 5)
    else
      from.minutes(0)

    query = 
      '_id.ep': req.params.endpoint
      '_id.path':
        $in: req.query.resources
      '_id.ts':
        $gte: from.toDate()
        $lt: to.toDate()

    measurements.findAggregatedAsync agg, query
    .then (data) ->
      res.send data
    .catch (err) ->
      res.status(500).send(err.message).end()

# https://github.com/chriso/validator.js
# custom validators in express.coffee
isValidRequest = (req, res) ->
  req.checkQuery('from').isISODate()
  req.checkQuery('to').isISODate()
  req.checkQuery('resources').isArray()

  if errors = req.validationErrors()
    res.status(400).send 
      errors: errors
  
  not errors

formatData = (data) ->
  for measurement in data
    measurement.ts = mongo.dateFromObjectId measurement._id
    delete measurement._id
    delete measurement.endpoint

  data
