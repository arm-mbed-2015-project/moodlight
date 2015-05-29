moment = require 'moment'

module.exports = (mongo) ->
  '30s': [
    _id: mongo.objectIdFromDate moment.utc('2015-03-01T15:00:01.978Z').toDate()
    ep: 'node-001'
    path: '/sen/temp'
    value: 10
  ,
    _id: mongo.objectIdFromDate moment.utc('2015-03-01T15:01:01.978Z').toDate()
    ep: 'node-001'
    path: '/sen/temp'
    value: 20
  ,
    _id: mongo.objectIdFromDate moment.utc('2015-03-01T15:01:29.978Z').toDate()
    ep: 'node-001'
    path: '/sen/temp'
    value: 30
  ]

  '30s-results': [
    _id:
      ep: 'node-001'
      path: '/sen/temp'
      ts: moment.utc('2015-03-01T15:00:00.000Z').toDate()
    value:
      count: 1
      total: 10
      max: 10
      min: 10
      avg: 10
  ,
    _id:
      ep: 'node-001'
      path: '/sen/temp'
      ts: moment.utc('2015-03-01T15:01:00.000Z').toDate()
    value:
      count: 2
      total: 50
      max: 30
      min: 20
      avg: 25
  ]

  '5m': [
    _id: mongo.objectIdFromDate moment.utc('2015-03-01T15:01:46.978Z').toDate()
    ep: 'node-001'
    path: '/sen/temp'
    value: 10
  ,
    _id: mongo.objectIdFromDate moment.utc('2015-03-01T15:12:47.178Z').toDate()
    ep: 'node-001'
    path: '/sen/temp'
    value: 20
  ,
    _id: mongo.objectIdFromDate moment.utc('2015-03-01T15:13:48.980Z').toDate()
    ep: 'node-001'
    path: '/sen/temp'
    value: 30
  ]

  '5m-results': [
    _id:
      ep: 'node-001'
      path: '/sen/temp'
      ts: moment.utc('2015-03-01T15:00:00.000Z').toDate()
    value:
      count: 1
      total: 10
      max: 10
      min: 10
      avg: 10
  ,
    _id:
      ep: 'node-001'
      path: '/sen/temp'
      ts: moment.utc('2015-03-01T15:10:00.000Z').toDate()
    value:
      count: 2
      total: 50
      max: 30
      min: 20
      avg: 25
  ]

  'hourly': [
    _id: mongo.objectIdFromDate moment.utc('2015-03-01T15:01:46.978Z').toDate()
    ep: 'node-001'
    path: '/sen/temp'
    value: 10
  ,
    _id: mongo.objectIdFromDate moment.utc('2015-03-01T16:12:46.978Z').toDate()
    ep: 'node-001'
    path: '/sen/temp'
    value: 20
  ,
    _id: mongo.objectIdFromDate moment.utc('2015-03-01T16:34:48.980Z').toDate()
    ep: 'node-001'
    path: '/sen/temp'
    value: 30
  ]

  'hourly-results': [
    _id:
      ep: 'node-001'
      path: '/sen/temp'
      ts: moment.utc('2015-03-01T15:00:00.000Z').toDate()
    value:
      count: 1
      total: 10
      max: 10
      min: 10
      avg: 10
  ,
    _id:
      ep: 'node-001'
      path: '/sen/temp'
      ts: moment.utc('2015-03-01T16:00:00.000Z').toDate()
    value:
      count: 2
      total: 50
      max: 30
      min: 20
      avg: 25
  ]

  'daily': [
    _id: mongo.objectIdFromDate moment.utc('2015-03-01T13:37:46.978Z').toDate()
    ep: 'node-001'
    path: '/sen/temp'
    value: 10
  ,
    _id: mongo.objectIdFromDate moment.utc('2015-03-02T13:37:46.978Z').toDate()
    ep: 'node-001'
    path: '/sen/temp'
    value: 20
  ,
    _id: mongo.objectIdFromDate moment.utc('2015-03-02T23:37:48.980Z').toDate()
    ep: 'node-001'
    path: '/sen/temp'
    value: 30
  ]

  'daily-results': [
    _id:
      ep: 'node-001'
      path: '/sen/temp'
      ts: moment.utc('2015-03-01T00:00:00.000Z').toDate()
    value:
      count: 1
      total: 10
      max: 10
      min: 10
      avg: 10
  ,
    _id:
      ep: 'node-001'
      path: '/sen/temp'
      ts: moment.utc('2015-03-02T00:00:00.000Z').toDate()
    value:
      count: 2
      total: 50
      max: 30
      min: 20
      avg: 25
  ]
