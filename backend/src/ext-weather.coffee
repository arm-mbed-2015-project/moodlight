Promise = require 'bluebird'
rp = require 'request-promise'
_ = require 'lodash'

cfg = require '../config'

app = null
endpoints = null
settings = null
utility = null
self = exports

apiKey = cfg.openWeatherApiKey
API_URL = "http://api.openweathermap.org/data/2.5/weather?APPID=#{apiKey}"

############################################

self.name = 'ext-weather'

self.attach = (opts) ->
  app = this

self.init = (done) ->
  endpoints = app.plugins['models/endpoints']
  settings = app.plugins['models/settings']
  utility = app.plugins['utility']
  done()

self.isWeatherMode = (modeNum) ->
  modeNum == 2

###*
 * Update the color of the given endpoints, or all endpoints, if passed 
 * array is empty.
 * 
 * @param  {Array} endpoints Array of endpoints to update
 * @return {Promise} promise A promise that resolves with an array of the set
 *                           colors.
###
self.updateOnce = (eps) ->
  endpoints.listOnline()
  .filter (ep) ->
    if eps.length and not _.includes(eps, ep)
      return false

    endpoints.getMode ep
    .then (modeNum) ->
      self.isWeatherMode(modeNum)

  .map (ep) ->
    getCityFromSettings ep
    .then (cityOrId) ->
      self.get cityOrId
    
    .then (data) ->
      tempCelsius = utility.kelvinToCelsius data.main.temp
      @rgba = calculateRgba tempCelsius
      endpoints.setColor ep, @rgba
    
    .then ->
      @rgba

###*
 * Tries to get the current weather conditions based on the city or id.
 *
 * City format should be like this: Oulu, FI
 * You can look up ids at: http://openweathermap.org/find
 *
 * Example response
 *
 * { coord: { lon: 25.47, lat: 65.01 },
 *   sys: 
 *    { message: 2.2167,
 *      country: 'FI',
 *      sunrise: 1430616892,
 *      sunset: 1430679306 },
 *   weather: [ { id: 500, main: 'Rain', description: 'light rain', icon: '10n' } ],
 *   base: 'stations',
 *   main: 
 *    { temp: 275.658,
 *      temp_min: 275.658,
 *      temp_max: 275.658,
 *      pressure: 1011.3,
 *      sea_level: 1015.36,
 *      grnd_level: 1011.3,
 *      humidity: 99 },
 *   wind: { speed: 3.56, deg: 11.0085 },
 *   clouds: { all: 92 },
 *   rain: { '3h': 1.375 },
 *   dt: 1430614250,
 *   id: 643492,
 *   name: 'Oulu',
 *   cod: 200 }
 * 
 * @param  {String|Number} cityOrId
 * @return {Promise}
###
self.get = (cityOrId) ->
  getWeather q: cityOrId
  .catch (err) ->
    getWeather id: cityOrId

############################################

getCityFromSettings = (ep) ->
  settings.findAsync ep
  .then (res) ->
    unless res and res.city and res.city.length
      throw new Error 'bad city'
    res.city

  .catch ->
    cfg.backend.openWeatherDefaultCity

# possible further development: use configurable, from opts in self.attach
# and for that would need a generic function that takes in an array of
# 'keyframes'
# 
# right now this goes like so:
# -40    -20     0    20   40
# red   yellow green cyan blue
calculateRgba = (tempCelsius) ->
  threshold = 
    low: -40
    middle: 0
    high: 40

  rgba = r: 0, g: 0, b: 0, a: 255

  if tempCelsius <= 0
    ratio = -tempCelsius / 40
    ratio = 1 if ratio > 1

    rgba.r = ratio * 255
    rgba.g = 255 - rgba.r  

  else
    ratio = tempCelsius / 40
    ratio = 1 if ratio > 1

    rgba.b = ratio * 255
    rgba.g = 255 - rgba.b

  rgba

getWeather = (query) ->
  rp.get 
    url: API_URL
    json: true
    qs: query

  .then (res) ->
    statusCode = res.cod and parseInt(res.cod)
    badStatusCode = statusCode and statusCode >= 400
    haveErrorMessage = res.message?.match /^Error/

    if badStatusCode or haveErrorMessage
      throw new Error(res.message or 'unknown error')

    res
