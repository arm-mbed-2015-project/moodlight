Promise = require 'bluebird'

module.exports = (app) ->
  app.controller 'DashboardCtrl', ['$scope', '$rootScope', '$timeout', 'mode',
  ($scope, $rootScope, $timeout, mode) ->        
    $scope.modeOptions = ['Manual', 'Music', 'Weather/Light/Motion']
    $scope.state = 
      online: false
      mode: 0
    
    $scope.modeChanged = (newMode) ->
      prevMode = $scope.state.mode

      mode.set newMode
      .then ->
        return unless isManualMode(newMode)
        mode.setManualColor $scope.manual.color
          
      .catch (err) ->
        console.log 'mode.set error', err
        $scope.state.online = false
        init()

    $scope.showControls = ->
      isManualMode $scope.state.mode

    isManualMode = (modeValue) ->
      modeValue is 0

    $scope.manual = 
      spinning: 0
      color: 'rgb(255, 0, 0, 0.50)'

    $scope.$on 'colorpicker-selected', (e, data) ->
      $timeout ->
        $scope.$apply ->
          mode.setManualColor $scope.manual.color
      , 0

    $scope.$watch 'manual.spinning', (val, oldval) ->
      $scope.manualSpinningChanged()

    $scope.manualSpinningChanged = ->
      mode.setManualSpinning $scope.manual.spinning

    destroyed = false
    $scope.$on '$destroy', ->
      destroyed = true

    init = ->
      return if destroyed

      mode.get()
      .then (value) ->
        $scope.$apply ->
          $scope.state.online = true
          $scope.state.mode = value

      .catch (err) ->
        console.log 'mode.get error', err
        console.log 'trying again in 5 sec'
        $timeout init, 5000

    init()
  ]
