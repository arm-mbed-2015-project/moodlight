Promise = require 'bluebird'
moment = require 'moment'
_ = require 'lodash'

app = null
express = null
client = null
measurements = null

self = exports
self.name = 'rest-api/resources'

self.attach = (opts) ->
  app = this

self.init = (done) ->
  express = app.plugins['express']
  client = app.plugins['device-server/client'].client
  measurements = app.plugins['models/measurements']
  register()
  done()

############################################

register = ->
  express.app.get '/endpoints/:endpoint/resources', (req, res, next) ->
    if req.query.stats_only
      listFn = listResourcesInDatabase
    else
      listFn = listAllResources

    listFn req.params.endpoint
    .then (resources) ->
      res.send resources
    .catch (err) ->
      res.status(500).send(err.message).end()

  express.app.get '/endpoints/:endpoint/resources/:resource', (req, res, next) ->
    client.resource req.params.endpoint, req.params.resource, 'GET'
    
    .then (value) ->
      res.send value: value
    
    .catch (err) ->
      return res.status(410).end() if err.statusCode is 410
      throw err
    
    .catch (err) ->
      res.status(500).send(err.message).end()

  express.app.put '/endpoints/:endpoint/resources/:resource', (req, res, next) ->
    client.resource req.params.endpoint, 
                    req.params.resource, 
                    'PUT', 
                    null, 
                    req.body.value
    
    .then ->
      if req.params.resource == 'mode'
        app.emit 'resources::modeChanged', 
          endpoint: req.params.endpoint
          mode: req.body.value

      res.status(204).end()
      
    .catch (err) ->
      return res.status(410).end() if err.statusCode is 410
      throw err
    
    .catch (err) ->
      res.status(500).send(err.message).end()

############################################

listAllResources = (endpoint) ->
  Promise.all [listResourcesInDatabase(endpoint), 
               listResourcesOnline(endpoint)]
  .then (results) ->
    _(results).flatten().uniq().compact().value()

listResourcesInDatabase = (endpoint) ->
  measurements.getResourcesInDatabaseAsync endpoint

listResourcesOnline = (endpoint) ->
  client.endpointMeta endpoint
  .then (data) ->
    _.map data, (item) -> item.uri
  .catch (err) ->
    # 404 means node isn't online, it's not an error
    throw err unless err.statusCode is 404
