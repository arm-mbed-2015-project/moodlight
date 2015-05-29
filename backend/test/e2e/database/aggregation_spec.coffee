require 'coffee-errors'

chai = require 'chai'
chaiAsPromised = require 'chai-as-promised'
chai.use chaiAsPromised
sinon = require 'sinon'
sinonChai = require 'sinon-chai'
chai.use sinonChai
expect = chai.expect
context = describe

# http://mochajs.org/
# http://chaijs.com/api/bdd/
# http://chaijs.com/plugins/chai-as-promised
# http://sinonjs.org/docs/
# https://github.com/domenic/sinon-chai

############################################

Promise = require 'bluebird'
broadway = require 'broadway'
moment = require 'moment'
_ = require 'lodash'

app = new broadway.App()

app.use require('../../../src/database/mongo'), 
  url: 'mongodb://localhost:27017/test'

app.use require('../../../src/database/aggregation'),
  updateIntervalSeconds: 10000 # to skip updating by timer

mongo = app.plugins['database/mongo']
aggregation = app.plugins['database/aggregation']
fixtures = require('./aggregation-fixtures')(mongo)

db = {}

############################################

describe 'database/aggregation', ->
  before (done) ->
    app.on 'mongo::initialized', ->
      db.aggregation = mongo.db.collection 'aggregation'
      db.measurements = mongo.db.collection 'measurements'
      db['measurements-30s'] = mongo.db.collection 'measurements-30s'
      db['measurements-5m'] = mongo.db.collection 'measurements-5m'
      db['measurements-hourly'] = mongo.db.collection 'measurements-hourly'
      db['measurements-daily'] = mongo.db.collection 'measurements-daily'

    app.init done

  beforeEach ->
    cols = _.values db

    Promise.map cols, (col) ->
      col.dropAsync()
      .catch (err) ->
        throw err unless err.errmsg.match 'ns not found'

  context 'with no data', ->
    beforeEach ->
      aggregation.aggregateOnce().then =>
        @collections = mongo.db.collectionsAsync()

    it 'does not do anything', ->
      expect(@collections).to.eventually.not.include 'measurements-5m'
      expect(@collections).to.eventually.not.include 'measurements-daily'
      expect(@collections).to.eventually.not.include 'measurements-hourly'

  context 'with some data', ->
    context '30s', ->
      beforeEach ->
        Promise.map fixtures['30s'], (doc) -> 
          db.measurements.insertAsync doc
        
        .then ->
          aggregation.aggregateOnce()

        .then ->
          db['measurements-30s'].findAsync().call('toArrayAsync')
          
        .then (res) =>
          @results = res

      it 'aggregates the data successfully', ->
        expect(@results).to.have.length 2

      it 'groups the data by the starting 30 seconds', ->
        expect(@results).to.include fixtures['30s-results'][0]
        expect(@results).to.include fixtures['30s-results'][1]


    context '5m', ->
      beforeEach ->
        Promise.map fixtures['5m'], (doc) -> 
          db.measurements.insertAsync doc
        
        .then ->
          aggregation.aggregateOnce()

        .then ->
          db['measurements-5m'].findAsync().call('toArrayAsync')
          
        .then (res) =>
          @results = res

      it 'aggregates the data successfully', ->
        expect(@results).to.have.length 2

      it 'groups the data by the starting 5 minutes', ->
        expect(@results).to.include fixtures['5m-results'][0]
        expect(@results).to.include fixtures['5m-results'][1]

    context 'hourly', ->
      beforeEach ->
        Promise.map fixtures['hourly'], (doc) -> 
          db.measurements.insertAsync doc
        
        .then ->
          aggregation.aggregateOnce()

        .then ->
          db['measurements-hourly'].findAsync().call('toArrayAsync')
          
        .then (res) =>
          @results = res

      it 'aggregates the data successfully', ->
        expect(@results).to.have.length 2

      it 'groups the data by hour', ->
        expect(@results).to.include fixtures['hourly-results'][0]
        expect(@results).to.include fixtures['hourly-results'][1]

    context 'daily', ->
      beforeEach ->
        Promise.map fixtures['daily'], (doc) -> 
          db.measurements.insertAsync doc
        
        .then ->
          aggregation.aggregateOnce()

        .then ->
          db['measurements-daily'].findAsync().call('toArrayAsync')
          
        .then (res) =>
          @results = res

      it 'aggregates the data successfully', ->
        expect(@results).to.have.length 2

      it 'groups the data by day', ->
        expect(@results).to.include fixtures['daily-results'][0]
        expect(@results).to.include fixtures['daily-results'][1]

  context 'with some data already aggregated', ->
    beforeEach ->
      db.measurements.insertAsync fixtures['daily'][0]
      
      .then ->
        aggregation.aggregateOnce()

      .then ->
        Promise.map fixtures['daily'][1..], (doc) ->
          db.measurements.insertAsync doc

      .then ->
        aggregation.aggregateOnce()

      .then ->
        db['measurements-daily'].findAsync().call('toArrayAsync')
        
      .then (res) =>
        @results = res

    it 'only processes new data', ->
      expect(@results).to.have.length 2
      expect(@results).to.include fixtures['daily-results'][0]
      expect(@results).to.include fixtures['daily-results'][1]

