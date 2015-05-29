Promise = require 'bluebird'

module.exports = (app) ->
  app.factory 'mode', ['$rootScope', '$http', 'backendAddr',
  ($rootScope, $http, backendAddr) ->
    new class ModeService
      get: ->
        new Promise (resolve, reject) =>
          $http.get @_uri('mode'),
            params:
              _t: new Date().getTime() # to prevent caching

          .success (data, status, headers, config) ->
            resolve parseInt data.value

          .error (data, status, headers, config) ->
            reject data
      
      set: (mode) ->
        new Promise (resolve, reject) =>
          $http.put @_uri('mode'), 
            value: mode

          .success (data, status, headers, config) ->
            resolve()

          .error (data, status, headers, config) ->
            reject data

      setManualColor: (rgba) ->
        new Promise (resolve, reject) =>
          $http.put @_uri('led_color'), 
            value: @_toDec rgba

          .success (data, status, headers, config) ->
            resolve()

          .error (data, status, headers, config) ->
            reject data

      _toDec: (rgba) ->
        m = rgba.match(///
        ^rgba?\(
        ([\d\.]+) # R
        [\.\s,]+
        ([\d\.]+) # G
        [\.\s,]+
        ([\d\.]+) # B
        [\.\s,]+
        ([\d\.]+) # A
        \)$
        ///)

        m[4] = parseFloat(m[4]) * 255

        r = parseInt m[1]
        g = parseInt m[2]
        b = parseInt m[3]
        a = parseInt m[4]

        dec = a
        dec += b << 8
        dec += g << 16
        dec += r << 24
        dec

      getManualSpinning: ->
        new Promise (resolve, reject) =>
          $http.get @_uri('led_spinning'),
            params:
              _t: new Date().getTime() # to prevent caching

          .success (data, status, headers, config) ->
            resolve parseInt data.value

          .error (data, status, headers, config) ->
            reject data

      setManualSpinning: (spinning) ->
        new Promise (resolve, reject) =>
          $http.put @_uri('led_spinning'), 
            value: spinning

          .success (data, status, headers, config) ->
            resolve()

          .error (data, status, headers, config) ->
            reject data

      _uri: (resource) ->
        "#{backendAddr}/endpoints/#{$rootScope.endpoint}/resources/#{resource}"
  ]
