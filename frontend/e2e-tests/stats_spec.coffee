Promise = require 'bluebird'

chai = require 'chai'
chaiAsPromised = require 'chai-as-promised'
chai.use chaiAsPromised
expect = chai.expect

StatsPage = require './stats_page'
helpers = require './helpers'

describe 'stats page', ->
  before ->
    @statsPage = new StatsPage
    @statsPage.get 'node-001'

  it 'does not show any statistics initially'
  it 'lists all the available resources in a dropdown'
  it 'updates the graph when resources are (de)selected'
  it 'shows date/time pickers for from/to'
  it 'does not let you set a negative interval'

