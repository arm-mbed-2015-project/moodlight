Promise = require 'bluebird'
mongodb = require 'mongodb'
Promise.promisifyAll mongodb

MongoClient = mongodb.MongoClient
ObjectID = mongodb.ObjectID
app = null

############################################

exports.name = 'database/mongo'

exports.attach = (opts) ->
  app = this
  exports.url = opts.url or 'mongodb://localhost:27017/armiot2015'

exports.init = (done) ->
  MongoClient.connectAsync exports.url
  .then (db) ->
    exports.db = db
    app.emit 'mongo::initialized'
    done()
  
  .catch done

exports.objectIdFromDate = (date) ->
  str = Math.floor(date.getTime() / 1000).toString(16) + "0000000000000000"
  new ObjectID str

exports.dateFromObjectId = (objectId) ->
  objectId?.getTimestamp?() or 
  new Date(parseInt(objectId.substring(0, 8), 16) * 1000)
