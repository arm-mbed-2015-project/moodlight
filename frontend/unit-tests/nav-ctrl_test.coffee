describe 'NavCtrl', ->
  $scope = null

  beforeEach module('placeholderApp')
  
  beforeEach(inject ($rootScope, $controller) ->
    $scope = $rootScope.$new()
    $controller 'NavCtrl', 
      $scope: $scope
      $rootScope: $rootScope
  )

  it 'is initially collapsed', ->
    expect($scope.collapsed).to.eql true
