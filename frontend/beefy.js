var beefy = require('beefy');
var http = require('http');

http.createServer(beefy({
  entries: {
    '/bundle.js': 'src/coffee/main.coffee'
  },
  cwd: __dirname + '/app',
  // live: true,
  quiet: false,
  bundlerFlags: ['-t', 'coffeeify']
})).listen(8001)
