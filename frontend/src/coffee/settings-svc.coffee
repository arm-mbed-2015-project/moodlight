Promise = require 'bluebird'

module.exports = (app) ->
  app.factory 'settings', ['$rootScope', '$http', 'backendAddr',
  ($rootScope, $http, backendAddr) ->
    new class Settings
      get: ->
        uri = "#{backendAddr}/endpoints/#{$rootScope.endpoint}/settings"

        new Promise (resolve, reject) ->
          $http.get uri
          .success (data, status, headers, config) ->
            resolve data
          .error (data, status, headers, config) ->
            reject data

        .then (data) =>
          @data = data
          data

      save: (data) ->
        uri = "#{backendAddr}/endpoints/#{$rootScope.endpoint}/settings"

        new Promise (resolve, reject) ->
          $http.put uri, data
          .success (data, status, headers, config) ->
            resolve()
          .error (data, status, headers, config) ->
            reject data

        .then =>
          @data = data
  ]
