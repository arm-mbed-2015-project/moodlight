module.exports =
  backend: new class BackendConfig
    constructor: ->
      @port = 8646
      @openWeatherApiKey = 'you_api_key'
      @openWeatherDefaultCity = 'Oulu, FI'

  deviceServer: new class DeviceServerConfig
    constructor: ->
      @port = 8080
      @cwd = './device-server-devel-2.2.0-606/bin'
      @cmd = './runDS.sh'
      @args = -> []

  emulator: new class EmulatorConfig
    constructor: ->
      @port = 41601
      @ep = 'node-001'
      @cfg = "#{__dirname}/emulator.json"
      @cwd = './node-emulator-devel-2.2.0-603/bin'
      @cmd = './node-emulator.sh'
      @args = -> ['-def', @cfg, '-ds', '127.0.0.1', '-ep', @ep, '-p', @port]
