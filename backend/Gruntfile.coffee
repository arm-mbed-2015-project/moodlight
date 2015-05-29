spawn = require('child_process').spawn
fs = require 'fs'
cfg = require './config'

module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'

    coffeeCoverage:
      options:
        path: 'relative'

      src:
        src: 'src/'
        dest: 'src/'

    watch:
      coffee:
        files: ['src/**/*.coffee', 'test/**/*.coffee']
        tasks: ['test']

  grunt.loadNpmTasks 'grunt-coffee-coverage'
  grunt.loadNpmTasks 'grunt-contrib-watch'

  ###################################################################

  # JavaScript files from src dir need to be removed before running the tests!
  # Otherwise the test will prefer those, and they'll be out of date since
  # they'll only be recompiled AFTER the test passes...
  grunt.registerTask 'test', ['remove-coffee', 'test-run']
  
  grunt.registerTask 'remove-coffee', ->
    for file in grunt.file.expand 'src/**/*.js'
      grunt.file.delete file

  grunt.registerTask 'test-run', ->
    done = @async()
    suite = if grunt.option('e2e') then 'e2e' else 'unit'

    args = ['--compilers', 'coffee:coffee-script/register',
            '--recursive']
    args.push '--debug' if grunt.option('debug')
    args.push "./test/#{suite}"

    child = spawn 'node_modules/.bin/mocha', args, stdio: 'inherit'

    child.on 'close', (exitCode) ->
      ok = exitCode == 0
      done ok

  ###################################################################

  grunt.registerTask 'coverage', ['coffeeCoverage', 'coverageRun']

  grunt.registerTask 'coverageRun', ->
    done = @async()
    suite = if grunt.option('e2e') then 'e2e' else 'unit'

    args = ['--require', 'coffee-coverage/register', 
            '--compilers', 'coffee:coffee-script/register', 
            '--reporter', 'html-cov', 
            '--bail',
            '--recursive',
            "./test/#{suite}"]

    child = spawn 'node_modules/.bin/mocha', args
    
    child.stdout.pipe fs.createWriteStream('coverage.html')
    child.stderr.pipe process.stderr

    child.on 'close', (exitCode) ->
      ok = exitCode == 0
      done ok

  ###################################################################
  
  grunt.registerTask 'device-server', ->
    done = @async()
    child = spawn cfg.deviceServer.cmd, cfg.deviceServer.args(), 
      stdio: 'inherit'
      cwd: cfg.deviceServer.cwd
    child.on 'close', done

  grunt.registerTask 'emulator', ->
    done = @async()
    child = spawn cfg.emulator.cmd, cfg.emulator.args(), 
      stdio: 'inherit'
      cwd: cfg.emulator.cwd
    child.on 'close', done

  ###################################################################

  grunt.registerTask 'default', ['test', 'coverage', 'watch']
