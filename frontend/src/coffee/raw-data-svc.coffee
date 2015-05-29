_ = require 'lodash'
moment = require 'moment'

module.exports = (app) ->
  app.factory 'rawData', ['$rootScope', 'io', 'Flot'
  ($rootScope, io, Flot) ->
    new class RawData
      constructor: ->
        @flot = new Flot()
        @period = 20
        @flotEmpty()

        $rootScope.$on 'io::newData', (e, newData) =>
          _.extend @data, newData
          @flotAdd newData
          @flotClean @period
          $rootScope.$emit 'rawData::update'

        $rootScope.$watch 'endpoint', =>
          @flotEmpty()
          setTimeout ->
            $rootScope.$emit 'rawData::update'
          , 0

      flotAdd: (data) ->
        now = moment().unix() * 1000

        for key, value of data
          @flot.add key, [now, value]

      flotEmpty: ->
        @flot.empty()
        @data = {}
        @flotData = @flot.data

      flotClean: (period) ->
        lastShownTimestamp = 
          moment().subtract(period, 'seconds').unix() * 1000

        for series in @flot.data
          @flot.clean series, (item) ->
            [timestamp, value] = item
            timestamp < lastShownTimestamp
  ]
