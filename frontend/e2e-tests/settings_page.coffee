module.exports = class SettingsPage
  constructor: ->
    @container = element By.id('main-container')

  get: (ep) ->
    browser.get "index.html#/endpoints/#{ep}/settings"

  urlMatches: ->
    browser.executeScript('return window.location.href;')
    .then (absUrl) ->
      !!absUrl.match(/\/settings/)
