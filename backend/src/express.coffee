express = require('express')()
bodyParser = require 'body-parser'
multer = require 'multer'
cors = require 'cors'
expressValidator = require 'express-validator'
moment = require 'moment'
Promise = require 'bluebird'
app = null
self = exports

############################################

self.name = 'express'

self.attach = (opts) ->
  app = this
  self.port = opts.port

  useBodyParsers()
  useCors()
  useValidator()

self.init = (done) ->
  @server = express.listen self.port, (err) =>
    return done err if err?

    host = @server.address().address
    port = @server.address().port

    console.log "Express listening at http://#{host}:#{port}"
    app.emit 'express::listening', @server
    
    done()

self.app = express

############################################

useBodyParsers = ->
  # application/json
  express.use bodyParser.json()

  # application/x-www-form-urlencoded
  express.use bodyParser.urlencoded extended: true
  
  # multipart/form-data
  express.use multer()

useValidator = ->
  express.use expressValidator(customValidators: customValidators)

customValidators =
  isISODate: (value) ->
    value and moment(value, moment.ISO_8601).isValid()

  isArray: (value) ->
    value and value instanceof Array

useCors = ->
  # dynamically whitelist every domain
  validator = (origin, callback) ->
    callback null, true

  express.use cors(origin: validator, credentials: true)
