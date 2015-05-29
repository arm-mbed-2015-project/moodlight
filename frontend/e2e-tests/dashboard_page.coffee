module.exports = class DashboardPage
  constructor: ->
    @container = element By.id('main-container')
    @modes = element.all By.css('.mode-selector a')

  get: (ep) ->
    browser.get "index.html#/endpoints/#{ep}/dashboard"

  urlMatches: ->
    browser.executeScript('return window.location.href;')
    .then (absUrl) ->
      !!absUrl.match(/\/dashboard/)
