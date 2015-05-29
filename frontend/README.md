# ARM IoT 2015 Frontend

This project is based on [angular-seed](https://github.com/angular/angular-seed).

## Installation

Install a few global npm packages with `npm install -g bower grunt-cli http-server`.

Copy or rename `app/config.sample.js` to `app/config.js` and edit the address (namely the port) for the backend if needed.

## Usage

Start server at [localhost:8001](http://localhost:8001/).

    npm start

Run unit tests with Karma.

    npm test

Run E2E tests with Protractor. Make sure to run `npm install -g mocha protractor` first. You also need to have set up the `../backend/config.coffee` so that the test framework can start the device server and node emulator. (And make sure they're not already running before running the tests!)

    npm run protractor

## Development

You'll need to have Ruby and the SASS gem installed for SASS compilation to work.

Install ruby with either by doing
    
    sudo apt-get install ruby

or following the instructions at [rvm.io](http://rvm.io/).

Then install the sass gem with

    gem install sass

- `grunt` compiles the CoffeeScript and SASS files and starts watching for changes.
- `grunt deploy` compiles the CoffeeScript and SASS files without source maps. 
