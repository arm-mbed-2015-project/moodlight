var helpers = require('./helpers');

exports.config = {
  allScriptsTimeout: 30000,
  specs: ['*_spec.coffee'],
  capabilities: {
    browserName: 'chrome'
  },
  baseUrl: 'http://localhost:8001/',

  framework: 'mocha',
  mochaOpts: {
    reporter: 'spec',
    timeout: 30000
  },

  onPrepare: function () {
    return helpers.start();
  },

  onCleanUp: function () {
    return helpers.kill();
  }
};
