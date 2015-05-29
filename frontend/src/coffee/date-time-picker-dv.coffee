module.exports = (app) ->
  app.directive 'dateTimePicker', ->
    restrict: 'E'
    templateUrl: 'views/date-time-picker.html'
    scope:
      model: '='

    link: 
      pre: (scope, element, attrs) ->
        scope.isOpen = false
        scope.options = {}
        scope.open = (e) ->
          e.preventDefault()
          e.stopPropagation()
          @isOpen = !@isOpen
