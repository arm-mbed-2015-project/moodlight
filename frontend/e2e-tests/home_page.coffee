module.exports = class HomePage
  constructor: ->
    @container = element By.id('main-container')

    @endpoint = {}
    @endpoint.select = element By.model('selected')
    @endpoint.options = @endpoint.select.all By.css('option')

  get: ->
    browser.get 'index.html'

  selectEndpoint: (endpoint) ->
    @endpoint.options.filter (el, index) ->
      el.getText().then (text) ->
        text.match endpoint
    .then (filteredElements) ->
      filteredElements[0].click()
