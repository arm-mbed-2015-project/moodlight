module.exports = (app) ->
  app.controller 'NavCtrl', ['$scope', '$rootScope', '$location',
  ($scope, $rootScope, $location) ->
    $scope.collapsed = true

    $scope.toggle = ->
      $scope.collapsed = !$scope.collapsed
    
    # collapse menu when location changes 
    # (e.g. when a link in the menu is clicked)
    $rootScope.$on '$locationChangeSuccess', (e, next, current) ->
      $scope.collapsed = true

    # need to set the initial value for the endpoint
    # handler below will update the rest
    parseEp = ->
      path = $location.path().split('/')

      if path.length > 2 and path[1] == 'endpoints'
        path[2]
      else
        null

    $rootScope.endpoint = parseEp()
    
    $rootScope.$on '$locationChangeSuccess', (e, value) ->
      if endpoint = parseEp()
        $rootScope.endpoint = endpoint

    $scope.endpointText = ->
      s = 'Moodlight'
      s += " #{$scope.endpoint}" if $scope.endpoint?
      s

    $scope.epLink = (path) ->
      if $scope.endpoint?
        "#/endpoints/#{$scope.endpoint}/#{path}"
      else
        ''

    $scope.links = [
      { path: 'presentation', text: 'Presentation'}
      { path: 'dashboard', text: 'Dashboard'}
      { path: 'stats', text: 'Statistics'}
      { path: 'settings', text: 'Settings'}
    ]

    $scope.epLinkClass = (path) -> 
      regex = new RegExp("^/endpoints/#{$scope.endpoint}/#{path}$")

      if $location.path().match regex
        'active'
      else
        ''
  ]
