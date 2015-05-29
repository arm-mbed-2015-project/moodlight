child_process = require 'child_process'

Promise = require 'bluebird'
Promise.promisifyAll child_process

cfg = require '../../backend/config'
pkg = require '../package.json'

ds = null
emu = null
backend = null
frontend = null

module.exports = 
  start: ->
    @startDeviceServer()
    .then =>
      @startEmulator()
    .then =>
      @startBackend()
    .then =>
      @startFrontend()

  kill: ->
    Promise.all [
      @killDeviceServer()
      @killEmulator()
      @killFrontend()
      @killBackend()
    ]

  startDeviceServer: ->
    console.log 'startDeviceServer'

    @killDeviceServer().then =>
      ds = child_process.spawn cfg.deviceServer.cmd, cfg.deviceServer.args(),
        cwd: cfg.deviceServer.cwd
      
      # quick fix, in reality should wait for data in stdout
      # /Started\./ to be exact
      Promise.delay 5000

  killDeviceServer: ->
    return Promise.resolve() unless ds?
    @_kill ds, 'device server'
    .then ->
      # does not want to die otherwise...
      regex = 'com\.arm\.mbed\.deviceserver\.devel\.DeviceServerDevel'
      child_process.execAsync "kill `pgrep -f '#{regex}'`"
      .catch (err) -> # ...
    
    .then -> 
      ds = null

  _kill: (child, name) ->
    console.log '_kill', name
    child.kill()
    Promise.resolve()
  
  startEmulator: ->
    console.log 'startEmulator'
    
    @killEmulator().then =>
      emu = child_process.spawn cfg.emulator.cmd, cfg.emulator.args(),
        cwd: cfg.emulator.cwd
      
      # quick fix, in reality should wait for data in stdout
      # /Registration state: REGISTERED/ to be exact
      Promise.delay 1000

  killEmulator: ->
    return Promise.resolve() unless emu?

    @_kill emu, 'emulator'
    .then ->
      # does not want to die otherwise...
      child_process.execAsync "kill `pgrep -f 'org\.mbed\.emulator\.App'`"
      .catch (err) -> # ...

    .then -> 
      emu = null
  
  startBackend: ->
    console.log 'startBackend'

    @killBackend().then =>
      backend = child_process.spawn 'node_modules/.bin/coffee', ['src/app.coffee'], 
        cwd: "#{__dirname}/../../backend"
      
      # quick fix, in reality should wait for data in stdout
      # /Pre-subscription set\./ to be exact
      Promise.delay 1000

  killBackend: ->
    return Promise.resolve() unless backend?
    @_kill backend, 'backend'
    .then -> backend = null
  
  startFrontend: ->
    console.log 'startFrontend'

    @killFrontend().then =>
      [bin, args...] = pkg.scripts.start.split ' '
      bin = "node_modules/.bin/#{bin}"

      frontend = child_process.spawn bin, args,
        cwd: "#{__dirname}/.."
      
      # quick fix, in reality should wait for data in stdout
      # /Pre-subscription set\./ to be exact
      Promise.delay 1000

  killFrontend: ->
    return Promise.resolve() unless frontend?
    @_kill frontend, 'frontend'
    .then -> frontend = null
