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

app.use require('../../src/ext-weather')
weather = app.plugins['ext-weather']

############################################

describe 'ext-weather', ->
  before (done) ->
    app.init done

  describe '#get', ->
    context 'with city and country code', ->
      before ->
        weather.get 'Oulu, FI'
        .then (res) =>
          @results = res

      it 'pulls correct data', ->
        expect(@results.id).to.eql 643492

    context 'with id', ->
      before ->
        weather.get 643492
        .then (res) =>
          @results = res

      it 'pulls correct data', ->
        expect(@results.name).to.eql 'Oulu'
