module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON "package.json"

    browserify:
      options:
        transform: ["coffeeify"]
        # watch: true

      dev:
        options:
          debug: true
        src: "./src/coffee/main.coffee"
        dest: "app/bundle.js"

      prod:
        src: "<%= browserify.dev.src %>"
        dest: "<%= browserify.dev.dest %>"


    sass:
      dev:
        src: ["src/sass/**/*.scss"]
        dest: "app/bundle.css"
      prod:
        sourcemap: "none"
        src: "<%= sass.dev.src %>"
        dest: "<%= sass.dev.dest %>"


    # while watchify works, it seems unreliable on some platforms because
    # it may not always completely write the bundle file
    watchify:
      options:
        debug: true

        callback: (b) ->
          b.transform "coffeeify"
          b

      dev:
        src: "<%= browserify.dev.src %>"
        dest: "<%= browserify.dev.dest %>"

    watch:
      coffee:
        files:  "src/coffee/**/*.coffee"
        tasks: ["browserify:dev"]
      sass:
        files: "<%= sass.dev.src %>"
        tasks: ["sass:dev"]

  grunt.loadNpmTasks "grunt-contrib-sass"
  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-browserify"
  grunt.loadNpmTasks "grunt-watchify"

  grunt.registerTask "default", ["browserify:dev", "sass:dev", "watch"]
  grunt.registerTask "deploy", ["browserify:prod", "sass:prod"]
