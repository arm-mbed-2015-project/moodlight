Promise = require 'bluebird'

module.exports = (app) ->
  app.controller 'EndpointSelectorCtrl', 
  ['$rootScope', '$scope', '$location', '$http', 'backendAddr',
  ($rootScope, $scope, $location, $http, backendAddr) ->
    getEndpoints = ->
      new Promise (resolve, reject) ->
        $http.get "#{backendAddr}/endpoints"
        .success (data, status, headers, config) ->
          resolve data
        .error (data, status, headers, config) ->
          reject data

    $scope.selected = $rootScope.endpoint

    getEndpoints().then (endpoints) ->
      $scope.$apply ->
        $scope.endpoints = endpoints

    $scope.go = ->
      return unless $scope.selected?
      $location.path "/endpoints/#{$scope.selected}/dashboard"
  ]
