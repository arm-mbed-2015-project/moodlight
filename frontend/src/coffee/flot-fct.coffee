_ = require 'lodash'
moment = require 'moment'

module.exports = (app) ->
  app.factory 'Flot', ['$rootScope', ($rootScope) ->
    class Flot
      constructor: ->
        @data = []

      ###*
       * Adds new data to the flot. 
       *
       * Data format: [x, y]
       *
       * @param {string} label
       * @param {array} item
      ###
      add: (label, newItem) ->
        series = @getSeries label
        
        if series.data.length is 0
          return series.data.push newItem

        exists = _.find series.data, (item) ->
          item[0] is newItem[0] and item[1] is newItem[1]
      
        @_append series, newItem unless exists?

      _append: (series, newItem) ->
        index = _.findIndex series.data, (item) ->
          item[0] > newItem[0]

        index = 0 if index < 0
        series.data.splice index, 0, newItem

      ###*
       * Finds or creates a series.
       *
       * The data format for a series is as follows:
       *
       * series =
       *   label: 'series one', 
       *   data: [
       *     [x1, y1]
       *     [x2, y2]
       *     [x3, y3]
       *     [x4, y4]
       *   ]
       * 
       * @param  {string} label
       * @return {object} series
      ###
      getSeries: (label) ->
        for series in @data
          return series if series.label is label

        @createSeries label

      ###*
       * Creates a new series. 
       * 
       * @param  {string} label
       * @return {object} series
      ###
      createSeries: (label) ->
        series = 
          label: label
          data: [] 

        @data.push series
        series

      ###*
       * Completely erases all the data.
      ###
      empty: ->
        @data = []

      ###*
       * Removes data points that the predicate returns truthy for.
      ###
      clean: (series, predicate) ->
        _.remove series.data, predicate
  ]
