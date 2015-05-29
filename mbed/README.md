ARM IoT 2015 mbed
========================

## Building

Open `src/main.h` and edit the server address and port.

Then install libc6-dev

```bash
sudo apt-get install libc6-dev
```

Get [arm-gcc-none-eabi](https://launchpad.net/gcc-arm-embedded) for your platform. Follow the [readme](https://launchpadlibrarian.net/200699979/readme.txt).

So basically, just download the binaries and set the PATH like so:

```bash
PATH=$PATH:/path/to/gcc-arm-none-eabi-*/bin
```

Then you can write `make` and the binary should be compiled for you.

## Unit Tests

Run `make` in the tests directory. This will compile, run and generate the coverage for all the tested modules. Tests can also be run individually with `make -C module_name [all] [run] [coverage]`. The tests have been written for Linux so you'll need MinGW or Cygwin if you want to run them on Windows. 

Compilation requires `make` and `g++`. Coverage reports are generated with `lcov`.
