module.exports = class StatsPage
  constructor: ->
    @container = element By.id('main-container')

  get: (ep) ->
    browser.get "index.html#/endpoints/#{ep}/stats"

  urlMatches: ->
    browser.executeScript('return window.location.href;')
    .then (absUrl) ->
      !!absUrl.match(/\/stats/)
