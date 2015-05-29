Promise = require 'bluebird'

module.exports = (app) ->
  app.controller 'ResourceSelectorCtrl', ['$scope', '$rootScope', '$http', 
                                          'backendAddr',
  ($scope, $rootScope, $http, backendAddr) ->
    $scope.settings = 
      externalIdProp: '' # full item is now returned
      # smartButtonMaxItems: 3
      # smartButtonTextConverter: (itemText, item) ->
      #   itemText

    $scope.options = []

    new Promise (resolve, reject) ->
      $http.get "#{backendAddr}/endpoints/#{$rootScope.endpoint}/resources",
        params:
          stats_only: true
      .success (data, status, headers, config) ->
        resolve data
      .error (data, status, headers, config) ->
        reject data
    
    .bind id: 1
    .map (resource) -> 
      id: @id++
      label: resource

    .then (items) ->
      $scope.$apply ->
        $scope.options = items

    .timeout 3000
  ]
