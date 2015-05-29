rp = require 'request-promise'
Promise = require 'bluebird'

app = null
requests = null

############################################

exports.name = 'device-server/client'

exports.attach = (options) ->
  app = this
  exports.client = new DeviceServerClient options

exports.init = (done) ->
  requests = app.plugins['device-server/requests']
  done()

############################################

class DeviceServerClient
  constructor: (opts) ->
    @host = opts.host or 'localhost'
    @port = opts.port or 8080
    @domain = opts.domain or 'domain'
    @user = opts.user or 'admin'
    @pass = opts.pass or 'secret'

  url: (path) ->
    "http://#{@user}:#{@pass}@#{@host}:#{@port}/#{@domain}#{path}"

  ###*
   * Lists the endpoints on the server.
   * @optional {object} query
   * @return {Promise} promise
   *
   * Example output (res.body):
   *
   * [{ "name":"node-001", "type":"Light", "status":"ACTIVE"},
   *  { "name":"node-002", "type":"Light", "status":"STALE"},
   *  { "name":"node-003", "type":"PowerNode", "status":"ACTIVE", "q": true}]
  ###
  endpoints: (query) ->
    rp.get 
      url: @url "/endpoints"
      json: true
      qs: query

  ###*
   * Returns information on an endpoint.
   * 
   * @param  {string} endpointName
   * @optional {object} query
   * @return {Promise} promise
   *
   * Example output (res.body):
   *
   * [{ "uri":"/dev/temp", "rt":"ucum:C", "obs":"true", "type":"text/plain"},
   *  { "uri":"/dev/illu", "obs":"false", "type":"text/plain"}]
  ###
  endpointMeta: (endpointName, query) ->
    rp.get 
      url: @url "/endpoints/#{endpointName}"
      json: true
      qs: query

  ###*
   * Access an endpoint's resource.
   * 
   * @param  {string} endpointName
   * @param  {string} resourcePath
   * @param  {string} method The http method. Supported: GET, PUT, POST, DELETE
   * @optional {object} query       
   * @optional {object} body Javascript object (that will be converted to JSON) 
   *                         used in the POST/PUT body.       
   * @return {Promise} promise
  ###
  resource: (endpointName, resourcePath, method, query, body) ->
    rp
      url: @url "/endpoints/#{endpointName}/#{resourcePath}"
      method: method
      json: true
      qs: query
      body: body
      
    .then (body) ->
      if typeof body == 'object' and body['async-response-id']
        asyncResponseId = body['async-response-id']
        requests.addAsync asyncResponseId

      else
        body

  ###*
   * Sets the pre-subsciptions.
   *
   * Pre-subscription means that an application sets a pattern that is 
   * automatically subscribed to all endpoints’ all resources that match it. 
   * The pattern can include an endpoint type, a list of resources, or an 
   * expression with an * character at the end. The pre-subscription concerns 
   * all the endpoints that are already registered and that will be registering
   * in the future. 
   *
   * Example:
   *
   * [{
   *   endpoint-type: "Light",
   *   resource-path: ["/sen/*"]
   * }, {
   *   endpoint-type: "Sensor"
   * }, {
   *   resource-path: ["/dev/temp", "/dev/hum"]
   * }]
   * 
   * @param  {string} endpointType
   * @param  {string} resourcePath
   * @return {Promise} promise
  ###
  preSubscribe: (patterns) ->
    rp.put 
      url: @url "/subscriptions"
      json: true
      body: patterns
  
  ###*
   * Returns a list of pre-subscriptions.
   * 
   * @return {promise} promise
  ###
  preSubscriptions: ->
    rp.get 
      url: @url "/subscriptions"
      json: true

  ###*
   * Subscribe to a resource.
   * 
   * @param  {string} endpointName
   * @param  {string} resourcePath
   * @optional {object} query       
   * @return {Promise} promise
   *
   * Example output (res.body):
   *
   * {"async-response-id": "5734979#node-001@test.domain.com/path1"}
  ###
  subscribe: (endpointName, resourcePath, query) ->
    rp.put 
      url: @url "/subscriptions/#{endpointName}/#{resourcePath}"
      json: true
      qs: query

  ###*
   * Unsubsribe from a resource/endpoint/domain. Specify both endpointName and
   * resourcePath to unsubscribe from a single resource. Specify just the
   * endpointName to remove all subscriptions from the endpoint. Leave both
   * out to remove all subscriptions.
   * 
   * @optional {string} endpointName
   * @optional {string} resourcePath
   * @return {Promise} promise
  ###
  unsubscribe: (endpointName, resourcePath) ->
    if endpointName and resourcePath
      rp.delete 
        url: @url "/subscriptions/#{endpointName}/#{resourcePath}"
        json: true

    else if endpointName
      rp.delete 
        url: @url "/subscriptions/#{endpointName}"
        json: true
    
    else
      rp.delete 
        url: @url "/subscriptions"
        json: true

  ###*
   * Checks whether the endpoint is subscribed. Promise is rejected if not.
   * 
   * @param  {string} endpointName
   * @param  {string} resourcePath
   * @return {Promise} promise
  ###
  isSubscribed: (endpointName, resourcePath) ->
    rp.get 
      url: @url "/subscriptions/#{endpointName}/#{resourcePath}"
      json: true

  ###*
   * Lists the endpoint's subscriptions.
   *
   * Example output:
   * 
   * Content-Type: text/uri-list
   * 
   * /example.com/subscriptions/node-001/dev/temp
   * /example.com/subscriptions/node-001/dev/power
   * 
   * @param  {string} endpointName
   * @return {Promise} promise             
  ###
  subscriptions: (endpointName) ->
    rp.get 
      url: @url "/subscriptions/#{endpointName}"
      headers:
        'Content-Type': 'text/uri-list'

  ###*
   * Sets the push notification url.
   * 
   * @optional {string}  pushUrl
   * @return   {Promise} promise
  ###
  setPushUrl: (pushUrl) ->
    @pushUrl = pushUrl or 'REMOTE_HOST'

    rp.put 
      url: @url "/notification/push-url"
      body: @pushUrl

  ###*
   * Removes the push notification url.
   * 
   * @return {Promise} promise
  ###
  removePushUrl: ->
    rp.delete 
      url: @url "/notification/push-url"
