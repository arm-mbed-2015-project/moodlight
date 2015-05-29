Promise = require 'bluebird'
_ = require 'lodash'

###*
 * DISCLAIMER: this view wasn't supposed to be in here at all, it was done as
 * 'a last minute change', in a few hours, by way of brute-force coding, so 
 * apologies in advance. :D
###

module.exports = (app) ->
  app.controller 'PresentationCtrl', ['$scope', '$rootScope', '$timeout', 'mode',
  ($scope, $rootScope, $timeout, mode) ->
    $scope.modeOptions = ['Manual', 'Music', 'Weather']
    $scope.fakeModeOptions = ['Color', 'Spinning', 'Random Spinning', 'Music', 
                              'Weather']

    $scope.state = 
      online: false
      mode: 0
      fakeMode: 0
      busy: true

    $scope.fakeModeChanged = (newFakeMode) ->
      $scope.state.busy = true
      promise = null

      # manual, not spinning
      if newFakeMode is 0
        promise = $scope.modeChanged 0
        .then ->
          $scope.$apply ->
            $scope.state.mode = 0
            $scope.state.fakeMode = newFakeMode
          mode.setManualSpinning 0

      # manual, spinning
      else if newFakeMode is 1
        promise = $scope.modeChanged 0
        .then ->
          $scope.$apply ->
            $scope.state.mode = 0
            $scope.state.fakeMode = newFakeMode
          mode.setManualSpinning 1

      # manual, fancy spinning
      else if newFakeMode is 2
        promise = $scope.modeChanged 0
        .then ->
          $scope.$apply ->
            $scope.state.mode = 0
            $scope.state.fakeMode = newFakeMode
          mode.setManualSpinning 2

      # music
      else if newFakeMode is 3
        promise = $scope.modeChanged 1
        .then ->
          $scope.$apply ->
            $scope.state.mode = 1
            $scope.state.fakeMode = newFakeMode

      # weather
      else
        promise = $scope.modeChanged 2
        .then ->
          $scope.$apply ->
            $scope.state.mode = 2
            $scope.state.fakeMode = newFakeMode

      promise.finally ->
        $scope.$apply ->
          $scope.state.busy = false
    
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
      color: 'rgba(255, 0, 0, 0.50)'

    $scope.$watch 'manual.color', (val, oldval) ->
      return unless isManualMode($scope.state.mode) and 
                    $scope.state.online and 
                    not $scope.state.busy

      $scope.state.busy = true

      mode.setManualColor val
      .finally ->
        $scope.$apply ->
          $scope.state.busy = false

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
        mode.getManualSpinning()

      .then (value) ->
        $scope.$apply ->
          if $scope.state.mode is 0
            # manual
            if value is 0
              $scope.state.fakeMode = 0
            
            # manual spinning
            else if value is 1
              $scope.state.fakeMode = 1

            # manual random spinning
            else
              $scope.state.fakeMode = 2


          # music
          else if $scope.state.mode is 1
            $scope.state.fakeMode = 3
          
          # weather
          else
            $scope.state.fakeMode = 4

      .then ->
        $scope.state.busy = false

      .catch (err) ->
        console.log 'mode.get error', err
        console.log 'trying again in 5 sec'
        $timeout init, 5000

    init()
  ]

  app.controller 'MotionCtrl', ['$scope', '$rootScope', 'rawData', 
  ($scope, $rootScope, rawData) ->
    $scope.motion = 0
    $scope.states = [
      { text: 'no motion', class: 'motion' }
      { text: 'motion', class: 'motion active' }
    ]

    $rootScope.$on 'rawData::update', (e, newData) =>
      $scope.$apply ->
        return unless rawData.data?['/sen/motion']
        $scope.motion = rawData.data['/sen/motion']

  ]

  app.controller 'TemperatureCtrl', ['$scope', '$rootScope', 'rawData', 
  ($scope, $rootScope, rawData) ->
    $scope.value = rawData?.data?['/sen/temperature'] or 25.483123

    $rootScope.$on 'rawData::update', (e, newData) =>
      $scope.$apply ->
        return unless rawData.data?['/sen/temperature']
        $scope.value = rawData.data['/sen/temperature']
  ]

  app.directive 'colorSliders', ->
    toRGBA = (color) ->
      rgba = color.rgba
      "rgba(#{rgba.r}, #{rgba.g}, #{rgba.b}, #{rgba.a})"

    restrict: 'E'
    template: '<div></div>'
    scope:
      rgbModel: '='

    link: (scope, element, attrs) ->
      $el = $(element)

      $el.ColorPickerSliders
        flat: true
        swatches: false
        previewformat: 'hsl'
        order:
          hsl: 1
          preview: 2
        
        onchange: _.debounce (container, color) ->
          scope.$apply ->
            scope.rgbModel = toRGBA color
        , 250

      scope.$on '$destroy', ->
        $el.trigger 'colorpickersliders.destroy'

