Promise = require 'bluebird'

chai = require 'chai'
chaiAsPromised = require 'chai-as-promised'
chai.use chaiAsPromised
expect = chai.expect

DashboardPage = require './dashboard_page'
helpers = require './helpers'

describe 'dashboard page', ->
  before ->
    @dashboardPage = new DashboardPage
    @dashboardPage.get 'node-001'

  context 'when endpoint is online', ->
    it 'keeps changing the values in the raw data table'
    it 'shows the mode selector'
    it 'lets you change the mode'

    context 'when mode is manual', ->
      it 'shows the led controls'

  context 'when endpoint is offline', ->
    before ->
      @dashboardPage.get 'offline-node'

    # FIXME: this hangs
    it.skip 'indicates that it is offline', ->
      expect(@dashboardPage.container.getText())
        .to.eventually.match /endpoint is offline/
