moment = require 'moment'
_ = require 'lodash'

module.exports = (app) ->
  app.controller 'StatsCtrl', ['$scope', '$rootScope', 'stats', 
  ($scope, $rootScope, stats) ->
    $scope.from = 
      date: moment().subtract(1, 'minute').toDate()

    $scope.to = 
      date: moment($scope.from.date).add(2, 'minute').toDate()

    #######################

    $scope.selectedSensors = []

    #######################

    $scope.flotData = {}
    $scope.flotOptions = 
      xaxis:
        mode: 'time'
        timezone: 'browser'
        timeformat: '%Y-%m-%d %H:%M:%S'

    #######################

    $scope.update = ->
      sensors = $scope.selectedSensors.map (item) -> item.label

      stats.get $scope.from.date, $scope.to.date, sensors
      .then (res) -> 
        $scope.$apply ->
          $scope.flotData = res

    $scope.update = _.debounce $scope.update, 500

    #######################

    $scope.$watch 'from.date | json', (value, oldValue) ->
      $scope.update() if value isnt oldValue

    $scope.$watch 'to.date | json', (value, oldValue) ->
      $scope.update() if value isnt oldValue

    $scope.$watch 'selectedSensors', (value, oldValue) ->
      $scope.update() if value isnt oldValue
    , true

    $scope.update()
  ]
