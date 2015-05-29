Promise = require 'bluebird'
moment = require 'moment'
_ = require 'lodash'

app = null
mongo = null
db = {}

self = exports

############################################

self.name = 'database/aggregation'

self.attach = (opts) ->
  app = this
  self.updateIntervalSeconds = opts?.updateIntervalSeconds or 10

self.init = (done) ->
  mongo = app.plugins['database/mongo']

  app.on 'mongo::initialized', ->
    db.aggregation = mongo.db.collection 'aggregation'
    db.measurements = mongo.db.collection 'measurements'
    db['measurements-5m'] = mongo.db.collection 'measurements-5m'
    db['measurements-hourly'] = mongo.db.collection 'measurements-hourly'
    db['measurements-daily'] = mongo.db.collection 'measurements-daily'

    startTimer()

  done()

self.aggregateOnce = ->
  Promise.all [
    aggregate30s() 
    aggregate5m()
    aggregateHourly()
    aggregateDaily()
  ]

############################################

startTimer = ->
  setTimeout aggregateLoop, self.updateIntervalSeconds * 1000

aggregateLoop = ->
  self.aggregateOnce().finally ->
    startTimer()

aggregate30s = ->
  aggregateGeneric '30s', ->
    d = @_id.getTimestamp()
    d.setUTCSeconds(d.getUTCSeconds() - d.getUTCSeconds() % 30)
    d.setUTCMilliseconds 0

    key = 
      ep: @ep
      path: @path
      ts: d

aggregate5m = ->
  aggregateGeneric '5m', ->
    d = @_id.getTimestamp()
    d.setUTCMinutes(d.getUTCMinutes() - d.getUTCMinutes() % 5)
    d.setUTCSeconds 0
    d.setUTCMilliseconds 0

    key = 
      ep: @ep
      path: @path
      ts: d

aggregateHourly = ->
  aggregateGeneric 'hourly', ->
    d = @_id.getTimestamp()
    d.setUTCMinutes 0
    d.setUTCSeconds 0
    d.setUTCMilliseconds 0

    key = 
      ep: @ep
      path: @path
      ts: d

aggregateDaily = ->
  aggregateGeneric 'daily', ->
    d = @_id.getTimestamp()
    d.setUTCHours 0
    d.setUTCMinutes 0
    d.setUTCSeconds 0
    d.setUTCMilliseconds 0

    key = 
      ep: @ep
      path: @path
      ts: d

aggregateGeneric = (field, keyFn) ->
  # console.log '>> aggregate', field

  findLatestObjectId(field).bind {}
  .then (res) ->
    @latest = res
    getPreviousObjectId(field)

  .then (res) ->
    @previous = res

  .then ->    
    map = ->
      key = keyFn.call this

      value =
        count: 1
        min: @value
        max: @value
        total: @value

      emit key, value

    reduce = (key, values) ->
      res =
        count: 0
        total: 0

      values.forEach (value) ->
        res.min = value.min if not res.min? or value.min < res.min
        res.max = value.max if not res.max? or res.max < value.max
        res.count += value.count
        res.total += value.total

      res

    finalize = (key, value) ->
      if value.count
        value.avg = value.total / value.count

      return value

    options = 
      query: 
        _id: {}
      scope:
        keyFn: keyFn
      finalize: finalize
      out:
        reduce: "measurements-#{field}"
        nonAtomic: true

    options.query._id['$gt'] = @previous if @previous?
    options.query._id['$lte'] = @latest if @latest?

    db.measurements.mapReduceAsync map, reduce, options

  .then ->
    updatePreviousObjectId field, @latest

  .catch (err) ->
    # console.log 'aggregation error', err

findLatestObjectId = ->
  db.measurements.findOneAsync null,
    sort: 
      _id: -1
  .then (res) ->
    res?._id
  # .tap (res) ->
  #   console.log 'findLatestObjectId', res

getPreviousObjectId = (field) ->
  db.aggregation.findOneAsync 
    _id: 'previousObjectIds'
  .then (res) ->
    res?[field]
  # .tap (res) ->
    # console.log 'getPreviousObjectId', res

updatePreviousObjectId = (field, id) ->
  query =
    _id: 'previousObjectIds'

  doc = 
    $set: {}

  doc['$set'][field] = id
  db.aggregation.updateAsync query, doc, upsert: true
