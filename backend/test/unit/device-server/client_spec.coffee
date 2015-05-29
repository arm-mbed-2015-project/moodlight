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

proxyquire = require('proxyquire').noCallThru()

rp = sinon.stub()
rp.get = sinon.stub()
rp.put = sinon.stub()
rp.delete = sinon.stub()

proxyquire '../../../src/device-server/client',
  'request-promise': rp

options = 
  host: 'hawst'
  port: 1337
  domain: 'do-mane'
  user: 'johndoe'
  pass: 'goal'

app = new broadway.App()
app.use require('../../../src/device-server/client'), options

requests = app.plugins['device-server/requests'] = 
  add: sinon.stub()
Promise.promisifyAll requests

client = app.plugins['device-server/client'].client

############################################

describe 'device-server/client', ->
  before (done) ->
    app.init done

  afterEach ->
    requests.add.reset()
    rp.reset()
    rp.get.reset()
    rp.put.reset()
    rp.delete.reset()

  describe '#attach', ->
    it 'sets the options', ->
      expect(client.host).to.equal options.host
      expect(client.port).to.equal options.port
      expect(client.domain).to.equal options.domain
      expect(client.user).to.equal options.user
      expect(client.pass).to.equal options.pass

  describe '#endpoints', ->
    it 'calls GET /endpoints', ->
      client.endpoints()
      expect(rp.get).to.have.been.called
      expect(rp.get.firstCall.args[0].url).to.match /\/endpoints$/

  describe '#endpointMeta', ->
    it 'calls GET /endpoints/:name', ->
      client.endpointMeta 'epname'
      expect(rp.get).to.have.been.called
      expect(rp.get.firstCall.args[0].url).to.match /\/endpoints\/epname$/

  describe '#resource', ->
    context 'when the call does not return an object', ->
      beforeEach ->
        rp.returns Promise.resolve('somevalue')
        @promise = client.resource 'ep', 'res', 'GET'

      it 'calls /endpoints/:name/:resource', ->
        expect(rp).to.have.been.called
        expect(rp.firstCall.args[0].url).to.match /\/endpoints\/ep\/res$/

      it 'returns the result', ->
        expect(@promise).to.eventually.equal 'somevalue'

    context 'when the call returns an object', ->
      beforeEach ->
        rp.returns Promise.resolve('async-response-id': 'abc123')
        requests.add.yields null, 'somevalue'
        @promise = client.resource 'ep', 'res', 'GET'

      it 'calls /endpoints/:name/:resource', ->
        expect(rp).to.have.been.called
        expect(rp.firstCall.args[0].url).to.match /\/endpoints\/ep\/res$/

      it 'saves the async response id', ->
        expect(requests.add).to.have.been.calledWith 'abc123'

      it 'returns the result', ->
        expect(@promise).to.eventually.equal 'somevalue'

  describe '#preSubscribe', ->
    it 'calls PUT /subscriptions/:name/:resource', ->
      patterns = [
        a: 'b'
        c: 'd'
      ]

      client.preSubscribe patterns
      expect(rp.put).to.have.been.called
      expect(rp.put.firstCall.args[0].body).to.eql patterns

  describe '#preSubscriptions', ->
    it 'calls GET /subscriptions', ->
      client.preSubscriptions()
      expect(rp.get).to.have.been.called
      expect(rp.get.firstCall.args[0].url).to.match /\/subscriptions$/

  describe '#subscribe', ->
    it 'calls PUT /subscriptions/:name/:resource', ->
      client.subscribe 'ep', 'res'
      expect(rp.put).to.have.been.called
      expect(rp.put.firstCall.args[0].url).to.match /\/subscriptions\/ep\/res$/

  describe '#unsubscribe', ->
    context 'with endpoint and resource', ->
      it 'calls DELETE /subscriptions/:name/:resource', ->
        client.unsubscribe 'ep', 'res'
        expect(rp.delete).to.have.been.called
        expect(rp.delete.firstCall.args[0].url)
          .to.match /\/subscriptions\/ep\/res$/
      
    context 'with just endpoint', ->
      it 'calls DELETE /subscriptions/:name', ->
        client.unsubscribe 'ep'
        expect(rp.delete).to.have.been.called
        expect(rp.delete.firstCall.args[0].url)
          .to.match /\/subscriptions\/ep$/

    context 'with no arguments', ->
      it 'calls DELETE /subscriptions', ->
        client.unsubscribe()
        expect(rp.delete).to.have.been.called
        expect(rp.delete.firstCall.args[0].url).to.match /\/subscriptions$/

  describe '#isSubscribed', ->
    it 'calls GET /subscriptions/:name/:resource', ->
      client.isSubscribed 'ep', 'res'
      expect(rp.get).to.have.been.called
      expect(rp.get.firstCall.args[0].url).to.match /\/subscriptions\/ep\/res$/

  describe '#subscriptions', ->
    it 'calls GET /subscriptions/:name', ->
      client.subscriptions 'ep'
      expect(rp.get).to.have.been.called
      expect(rp.get.firstCall.args[0].url).to.match /\/subscriptions\/ep$/

  describe '#setPushUrl', ->
    it 'calls PUT /notification/push-url', ->
      client.setPushUrl 'someurl'
      expect(rp.put).to.have.been.called
      arg = rp.put.firstCall.args[0]
      expect(arg.url).to.match /\/notification\/push-url$/
      expect(arg.body).to.equal 'someurl'

  describe '#removePushUrl', ->
    client.removePushUrl()
    expect(rp.delete).to.have.been.called
    expect(rp.delete.firstCall.args[0].url)
      .to.match /\/notification\/push-url$/
