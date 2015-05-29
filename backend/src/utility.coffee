_ = require 'lodash'

app = null

############################################

exports.name = 'utility'

exports.attach = (opts) ->
  app = this

exports.init = (done) ->
  done()

exports.decryptBase64 = (base64String) ->
  new Buffer(base64String, 'base64').toString()

exports.kelvinToCelsius = (k) ->
  k - 273.15

exports.celsiusToKelvin = (c) ->
  c + 273.15

exports.rgbaToHexColor = (rgba) ->
  hexStr = '0x'

  for dec in [rgba.r, rgba.g, rgba.b, rgba.a]
    hexStr += '0' if dec < 10
    hexStr += dec.toString(16)

  hexStr

exports.rgbaToDecColor = (rgba) ->
  dec = rgba.a
  dec += rgba.b << 8
  dec += rgba.g << 16
  dec += rgba.r << 24
  dec
