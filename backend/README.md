# ARM IoT 2015 Backend

## Installation

Make sure you have mongodb installed and running. Then do `npm install -g coffee-script grunt-cli`.

Copy and rename `config.sample.coffee` into `config.coffee`. Edit the options in there. If you don't want to start the device server or the node emulator via grunt then the only thing you need to edit is the device server port (which, by default, is 8080) and the openweather api key.

## Usage

- `grunt device-server` to start the device server
- `grunt emulator` to start the emulator
- `npm start` to start the web server
    + set the enviroment variable `BLUEBIRD_DEBUG=1` to enable long stack traces for promises

## Development

- `grunt` runs the tests, generates code coverage and starts watching for changes
- `grunt test` runs the tests once
- `grunt coverage` generates code coverage
- unit test suites are run by default, add `--e2e` to run e2e tests instead
    + e2e tests require you to run the device server and the node emulator via the grunt commands listed above
    + `database/aggregation` has integration tests but the coverage can not be generated for because the map/reduce functions are not run on the client. Furthermode, jscoverage adds garbage to the functions and MongoDB doesn't know what to do with it, so the functions won't even work.
