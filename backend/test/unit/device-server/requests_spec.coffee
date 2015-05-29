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

app = new broadway.App()
app.use require('../../../src/device-server/requests')
app.use require('../../../src/utility')
requests = app.plugins['device-server/requests']
utility = app.plugins['utility']

asyncResponses = app.plugins['models/async-responses'] = 
  find: sinon.stub()
  save: sinon.stub()

Promise.promisifyAll asyncResponses

############################################

describe 'device-server/requests', ->
  before (done) ->
    app.init done

  afterEach ->
    asyncResponses.find.reset()
    asyncResponses.save.reset()

  describe '#add', ->
    data = 
      'id': '923445392#node-001@domain/nw/ipaddr'
      'status': 200
      'payload': 'MjAwMTo6Mjox'
      'ct': 'text/plain'
      'max-age': 60 
    
    notification = 
      'async-responses': [data] 

    context 'when notification comes after adding', ->
      beforeEach ->
        @promise = requests.addAsync data.id
        app.emit 'events::notification', notification
        @promise

      it 'does not save anything to the database', ->
        expect(asyncResponses.save).to.not.have.been.called

      it 'returns the result', ->
        payload = utility.decryptBase64 data.payload
        expect(@promise).to.eventually.deep.equal payload

    context 'when notification comes before adding', ->
      beforeEach ->
        app.emit 'events::notification', notification
        asyncResponses.find.yields null,
          _id: data.id
          data: data
        @promise = requests.addAsync data.id

      it 'saves the notification to the database', ->
        expect(asyncResponses.save).to.have.been.called

      it 'resolves the promise from the database', ->
        expect(asyncResponses.find).to.have.been.called

      it 'returns the result', ->
        payload = utility.decryptBase64 data.payload
        expect(@promise).to.eventually.deep.equal payload
