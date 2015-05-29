module.exports = (app) ->
  app.controller 'RawDataCtrl', ['$scope', '$rootScope', 'rawData'
  ($scope, $rootScope, rawData) ->    
    $scope.flotOptions = 
      xaxis:
        mode: 'time'
        timezone: 'browser'

    $rootScope.$on 'rawData::update', ->
      $scope.$apply ->
        update()

    update = ->
      $scope.data = rawData.data
      $scope.flotData = rawData.flotData

    update()
  ]
