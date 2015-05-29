app = angular.module 'moodlightApp', [
  'ngRoute'
  'ngResource'
  'ui.bootstrap'
  'angular-flot'
  'angularjs-dropdown-multiselect'
  'colorpicker.module' # dashboard
]

app.constant 'backendAddr', window.cfg.backendAddr

app.config ['$routeProvider', ($routeProvider) ->
  $routeProvider
    .when '/endpoints/:endpoint/dashboard',
      templateUrl: 'views/dashboard.html'
      controller: 'DashboardCtrl'

    .when '/endpoints/:endpoint/stats',
      templateUrl: 'views/stats.html'
      controller: 'StatsCtrl'
    
    .when '/endpoints/:endpoint/settings',
      templateUrl: 'views/settings.html'
      controller: 'SettingsCtrl'

    .when '/endpoints/:endpoint/presentation',
      templateUrl: 'views/presentation.html'
      controller: 'PresentationCtrl'

    .when '/endpoints',
      templateUrl: 'views/endpoint-selector.html'
      controller: 'EndpointSelectorCtrl'

    .otherwise
      redirectTo: '/endpoints'
]

require('./nav-ctrl.coffee')(app)
require('./dashboard-ctrl.coffee')(app)
require('./presentation-ctrl.coffee')(app)
require('./raw-data-ctrl.coffee')(app)
require('./stats-ctrl.coffee')(app)
require('./settings-ctrl.coffee')(app)
require('./ep-selector-ctrl.coffee')(app)
require('./resource-selector-ctrl.coffee')(app)

require('./flot-fct.coffee')(app)

require('./raw-data-svc.coffee')(app)
require('./socket-io-svc.coffee')(app)
require('./stats-svc.coffee')(app)
require('./settings-svc.coffee')(app)
require('./mode-svc.coffee')(app)

require('./mode-selector-dv.coffee')(app)
require('./date-time-picker-dv.coffee')(app)
