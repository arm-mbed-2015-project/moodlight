var istanbul = require('browserify-istanbul');

module.exports = function (config) {
  config.set({
    basePath : './',
    files : [
      'app/bower_components/jquery/dist/jquery.js',
      'app/bower_components/angular/angular.js',
      'app/bower_components/angular-resource/angular-resource.js',
      'app/bower_components/angular-route/angular-route.js',
      'app/bower_components/angular-bootstrap/ui-bootstrap-tpls.js',
      'app/bower_components/angular-mocks/angular-mocks.js',
      'src/coffee/**/*.coffee',
      'unit-tests/**/*.coffee',
    ],
    
    autoWatch : true,
    frameworks: ['mocha', 'sinon-chai', 'browserify'],
    browsers : ['Chrome'],
    plugins : [
      'karma-chrome-launcher',
      'karma-coffee-preprocessor',
      'karma-coverage',
      'karma-browserify',
      'karma-mocha',
      'karma-sinon-chai',
    ],

    preprocessors: {
      'src/coffee/**/*.coffee': ['browserify'],
      'unit-tests/**/*.coffee': ['coffee'],
    },

    browserify: {
      debug: true,
      transform: ['coffeeify', istanbul({
        ignore: ['**/node_modules/**', '**/test/**'],
      })]
    },

    coffeePreprocessor: {
      options: {
        bare: false,
        sourceMap: true
      },
      transformPath: function (path) {
        return path.replace(/\.coffee$/, '.js');
      }
    },

    reporters: ['progress', 'coverage'],
    coverageReporter: {
      dir: 'coverage/',
      reporters: [
        { type: 'text', subdir: '.', file: 'text.txt' },

        // unable to write the detail pages for some reason, so can't be used
        // unless you do this hack...
        //
        // node_modules/karma-coverage/node_modules/istanbul/lib/report/html.js
        // 
        // this.opts.sourceStore = this.opts.sourceStore || Store.create('fslookup');
        // -->
        // this.opts.sourceStore = Store.create('fslookup');
        // { type: 'html', subdir: 'report-html' }, 
      ]
    },
  });
};
