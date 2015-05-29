Promise = require 'bluebird'

module.exports = (app) ->
  app.factory 'io', ['$rootScope', 'backendAddr',
  ($rootScope, backendAddr) ->
    new class SocketIO
      constructor: ->
        @io = window.io backendAddr
        @data = {}

        @io.on 'notifications', (newData) =>
          return unless $rootScope.endpoint?

          epData = newData[$rootScope.endpoint]
          $rootScope.$emit 'io::newData', epData

        @io.on 'error', (err) ->
          console.error 'socketio error', err
  ]
