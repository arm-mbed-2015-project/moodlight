Promise = require 'bluebird'
moment = require 'moment'

app = null
mongo = null
collection = null

############################################

exports.name = 'models/async-responses'

exports.attach = (opts) ->
  app = this

exports.init = (done) ->
  mongo = app.plugins['database/mongo']

  app.on 'mongo::initialized', ->
    collection = mongo.db.collection('asyncresponses')
    ensureIndexes().nodeify done

exports.save = (id, data, callback) ->
  collection.insert
    _id: id
    data: data,
    expireAt: moment().add(30, 'seconds').toDate()
  , callback

exports.find = (id, callback) ->
  collection.findOne _id: id, callback

exports.saveAsync = Promise.promisify exports.save
exports.findAsync = Promise.promisify exports.find
    
############################################

ensureIndexes =  ->
  spec = expireAt: 1
  options = expireAfterSeconds: 0
  collection.ensureIndexAsync spec, options
