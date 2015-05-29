Promise = require 'bluebird'

chai = require 'chai'
chaiAsPromised = require 'chai-as-promised'
chai.use chaiAsPromised
expect = chai.expect

HomePage = require './home_page'
DashboardPage = require './dashboard_page'

describe 'home page', ->
  before ->
    @homePage = new HomePage
    @homePage.get()

  it 'shows the endpoint selector', ->
    expect(@homePage.container.getText())
      .to.eventually.match /Please select an endpoint/

  it 'shows more than one endpoint', ->
    expect(@homePage.endpoint.options.count())
      .to.eventually.be.greaterThan 1 # index 0 is the empty option!

  context 'selecting an endpoint', ->
    before ->
      @dashboardPage = new DashboardPage
      @homePage.selectEndpoint 'node-001'

    it 'redirects to the dashboard', ->
      expect(@dashboardPage.urlMatches()).to.eventually.be.true

