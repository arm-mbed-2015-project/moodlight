require 'coffee-errors'

chai = require 'chai'
chaiAsPromised = require 'chai-as-promised'
chai.use chaiAsPromised
sinon = require 'sinon'
sinonChai = require 'sinon-chai'
chai.use sinonChai
expect = chai.expect
context = describe

# http://mochajs.org/
# http://chaijs.com/api/bdd/
# http://chaijs.com/plugins/chai-as-promised
# http://sinonjs.org/docs/
# https://github.com/domenic/sinon-chai

############################################

Promise = require 'bluebird'
broadway = require 'broadway'
moment = require 'moment'
_ = require 'lodash'

app = new broadway.App()

endpoints = app.plugins['models/endpoints'] = 
  listOnline: sinon.stub()
  getMode: sinon.stub()
  setColor: sinon.stub()

settings = app.plugins['models/settings'] = 
  findAsync: sinon.stub()

app.use require('../../src/utility')
utility = app.plugins['utility']

app.use require('../../src/ext-weather')
weather = app.plugins['ext-weather']

sinon.stub(weather, 'get')

############################################

describe 'ext-weather', ->
  before (done) ->
    app.init done

  afterEach ->
    stub.reset() for k, stub of endpoints
    stub.reset() for k, stub of settings
    weather.get.reset()

  describe '#updateOnce', ->
    context 'with no online nodes', ->
      beforeEach ->
        endpoints.listOnline.returns Promise.resolve([])
        weather.updateOnce().then (res) =>
          @results = res

      it 'does nothing', ->
        expect(@results).to.have.length 0
        expect(settings.findAsync).to.not.have.been.called
    
    context 'with an online node', ->
      context 'that is not in weather mode', ->
        beforeEach ->
          endpoints.listOnline.returns Promise.resolve(['some-node'])
          endpoints.getMode.returns Promise.resolve(1)
          weather.updateOnce().then (res) =>
            @results = res

        it 'does nothing', ->
          expect(@results).to.have.length 0
          expect(settings.findAsync).to.not.have.been.called

      context 'that is in weather mode', ->
        beforeEach ->
          @tempData =
            main:
              temp: utility.celsiusToKelvin 40

          endpoints.listOnline.returns Promise.resolve(['some-node'])
          endpoints.getMode.returns Promise.resolve(2)
          settings.findAsync.returns Promise.resolve('Mega City')
          weather.get.returns Promise.resolve(@tempData)
          endpoints.setColor.returns Promise.resolve()

          weather.updateOnce().then (res) =>
            @results = res

        it 'sets and returns the rgba colors', ->
          expect(@results).to.have.length 1
          expect(@results[0].b).to.eql 255
