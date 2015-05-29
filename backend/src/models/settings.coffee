Promise = require 'bluebird'
moment = require 'moment'
_ = require 'lodash'

app = null
mongo = null
collection = null

############################################

exports.name = 'models/settings'

exports.attach = (opts) ->
  app = this

exports.init = (done) ->
  mongo = app.plugins['database/mongo']

  app.on 'mongo::initialized', ->
    collection = mongo.db.collection('settings')

  done()

# inserts new or updates existing
exports.save = (endpoint, settings, callback) ->
  query = 
    _id: endpoint

  fullSettings = _.cloneDeep settings
  fullSettings._id = endpoint

  collection.update query, fullSettings, upsert: true, callback

exports.find = (endpoint, callback) ->
  collection.findOne _id: endpoint, (err, res) ->
    return callback err if err
    
    delete res._id if res?
    callback null, res

exports.saveAsync = Promise.promisify exports.save
exports.findAsync = Promise.promisify exports.find
