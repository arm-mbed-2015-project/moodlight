module.exports = (app) ->
  app.controller 'SettingsCtrl', ['$scope', '$rootScope', 'settings', 
  ($scope, $rootScope, settings) ->
    $scope.data = {}

    settings.get().then (data) ->
      $scope.$apply ->
        $scope.data = angular.copy data
        registerWatch()

    registerWatch = ->
      $scope.$watch 'data', (value, oldValue) ->
        save() if value isnt oldValue
      , true

    save = ->
      settings.save angular.copy($scope.data)

    $scope.formOptions = 
      updateOn: 'default blur'
      debounce:
        default: 1000
        blur: 1
  ]
