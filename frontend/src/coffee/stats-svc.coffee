Promise = require 'bluebird'
moment = require 'moment'
_ = require 'lodash'

TARGET_DATA_POINTS = 365

module.exports = (app) ->
  app.factory 'stats', ['$rootScope', '$http', 'Flot', 'backendAddr'
  ($rootScope, $http, Flot, backendAddr) ->
    new class Stats
      constructor: ->
        @flot = new Flot()
        @_intervals = [
          { interval: 1, fn: @getAll.bind(this) }
          { interval: 30, fn: @getAggregated.bind(this, '30s') }
          { interval: 300, fn: @getAggregated.bind(this, '5m') }
          { interval: 3600, fn: @getAggregated.bind(this, 'hourly') }
          { interval: 0, fn: @getAggregated.bind(this, 'daily') }
        ]

      ###*
       * Returns measurements based on the given criteria. It will fetch less
       * data points when the interval gets longer, but more if there aren't
       * enough data points.
       * 
       * @param  {Date} from
       * @param  {Date} to
       * @param  {Array} resources
       * @return {Promise}
      ###
      get: (from, to, resources) ->
        unless resources?.length and from?.toISOString and to?.toISOString
          return Promise.resolve [] 
        
        @_getEnoughDataPoints from, to, resources

      _getEnoughDataPoints: (from, to, resources) ->
        diffSeconds = moment(to).diff from, 'seconds', true

        if diffSeconds <= 0
          return Promise.resolve []

        index = @_matchInterval diffSeconds
        
        from = from.toISOString()
        to = to.toISOString()

        @_getRecursiveInterval index, from, to, resources

      _matchInterval: (timeSeconds) ->
        for item, index in @_intervals
          if timeSeconds <= @_calculateInterval(1 / item.interval)
            return index 

        index - 1 # because it will be same as .length

      _calculateInterval: (pointsPerSecond) ->
        # NOTE: assuming there's one data point per second
        TARGET_DATA_POINTS / pointsPerSecond

      _getRecursiveInterval: (index, from, to, resources) ->
        diffSeconds = moment(to).diff from, 'seconds', true 

        @_intervals[index].fn from, to, resources
        .then (flotData) =>
          return flotData if index is 0

          minDataPoints = TARGET_DATA_POINTS * resources.length
          numDataPoints = @_countDataPoints(flotData)
          notEnoughData = numDataPoints < minDataPoints

          ratio = @_intervals[index].interval / @_intervals[index - 1].interval
          smallerIntervalDataPoints = numDataPoints * ratio
          
          smallerIntervalWithTooMuchData =
            smallerIntervalDataPoints > 2 * minDataPoints

          if notEnoughData and not smallerIntervalWithTooMuchData
            console.log "not enough data (#{numDataPoints}), getting more"
            @_getRecursiveInterval index-1, from, to, resources
          
          else
            console.log "got #{numDataPoints} data points"
            flotData

      _countDataPoints: (flotData) ->
        sum = 0
        sum += series.data.length for series in flotData
        sum

      getAll: (from, to, resources) ->
        addr = "#{backendAddr}/endpoints/#{$rootScope.endpoint}/stats/all"
        @_get from, to, resources, addr, (item) ->
          resource: item.path
          timestamp: Date.parse item.ts
          value: item.value

      getAggregated: (agg, from, to, resources) ->
        addr = "#{backendAddr}/endpoints/#{$rootScope.endpoint}/stats/#{agg}"
        @_get from, to, resources, addr, (item) ->
          resource: item._id.path
          timestamp: Date.parse item._id.ts
          value: item.value.avg

      _get: (from, to, resources, url, mapFn) ->
        new Promise (resolve, reject) ->
          $http.get url, 
            params:
              from: from
              to: to
              'resources[]': resources
          .success (data, status, headers, config) ->
            resolve data
          .error (data, status, headers, config) ->
            reject data

        .then (data) =>
          @flot.empty()
          data
        
        .map mapFn

        .map (item) =>
          flotItem = [item.timestamp, item.value]
          @flot.add item.resource, flotItem
          flotItem

        .then =>
          @flot.data

        .catch (err) ->
          console.error err
          []
  ]

