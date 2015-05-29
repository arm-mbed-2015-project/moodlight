###*
 * Mode selector directive.
###
module.exports = (app) ->
  app.directive 'modeSelector', ->
    restrict: 'E'
    templateUrl: 'views/mode-selector.html'
    scope:
      model: '='
      options: '='
      onChange: '='
    link: (scope, element, attrs) ->
      scope.setMode = (id) ->
        scope.model = id
        scope.onChange(id)
