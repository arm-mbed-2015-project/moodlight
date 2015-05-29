Promise = require 'bluebird'

chai = require 'chai'
chaiAsPromised = require 'chai-as-promised'
chai.use chaiAsPromised
expect = chai.expect

SettingsPage = require './settings_page'
helpers = require './helpers'

describe 'settings page', ->
  before ->
    @settingsPage = new SettingsPage
    @settingsPage.get 'node-001'

  it 'shows the setting for a city'

  context 'when the city is changed', ->
    before ->
      @settingsPage.get 'node-001'
      Promise.delay 1000
    
    it 'stores the value'

