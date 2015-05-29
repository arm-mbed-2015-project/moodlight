#define CATCH_CONFIG_MAIN
#include "catch.hpp"

#include "fader.hpp"
using namespace moodlight;

TEST_CASE("fading down to zero") {
  unsigned int fade_time = 1000;
  Fader f (fade_time);

  // start at value = 100, t = 0
  // will fade down to value = 0 at t = fade_time
  f.GetValue(100, 0);

  SECTION("at t < 0") {
    f.GetValue(100, 5000); // start at t=5000
    double value = f.GetValue(666, 0); // get value at t=0
    REQUIRE(value == 666);
  }

  SECTION("at t = 0") {
    double value = f.GetValue(0, 0);
    REQUIRE(value == 100);
  }

  SECTION("at t = 1/4 * t0") {
    double value = f.GetValue(0, fade_time/4.0);
    REQUIRE(value == 7.0 / 8 * 100);
  }

  SECTION("at t = 1/2 * t0") {
    double value = f.GetValue(0, fade_time/2.0);
    REQUIRE(value == 50);
  }

  SECTION("at t = 3/4 * t0") {
    double value = f.GetValue(0, 3*fade_time/4.0);
    REQUIRE(value == 1.0 / 8 * 100);
  }

  SECTION("at t = t0") {
    double value = f.GetValue(0, fade_time);
    REQUIRE(value == 0);
  }

  SECTION("at t > t0") {
    double value = f.GetValue(0, fade_time * 2);
    REQUIRE(value == 0);
  }
}

TEST_CASE("going back up and then fading down") {
  unsigned int fade_time = 1000;
  Fader f (fade_time);

  unsigned int start_time = 0;

  // start at value = 100, t = 0
  // will fade down to value = 0 at t = fade_time
  f.GetValue(100, start_time);

  // now go over the fade_time, set a new value (because it's bigger)
  start_time = 2 * fade_time;
  f.GetValue(50, start_time);

  SECTION("at t = 0") {
    double value = f.GetValue(0, start_time);
    REQUIRE(value == 50);
  }

  SECTION("at t = 1/4 * t0") {
    double value = f.GetValue(0, start_time + fade_time/4.0);
    REQUIRE(value == 7.0 / 8 * 50);
  }

  SECTION("at t = 1/2 * t0") {
    double value = f.GetValue(0, start_time + fade_time/2.0);
    REQUIRE(value == 25);
  }

  SECTION("at t = 3/4 * t0") {
    double value = f.GetValue(0, start_time + 3*fade_time/4.0);
    REQUIRE(value == 1.0 / 8 * 50);
  }

  SECTION("at t = t0") {
    double value = f.GetValue(0, start_time + fade_time);
    REQUIRE(value == 0);
  }

  SECTION("at t > t0") {
    double value = f.GetValue(0, start_time + fade_time * 2);
    REQUIRE(value == 0);
  }
}

TEST_CASE("going back up and then fading down (2)") {
  unsigned int fade_time = 1000;
  Fader f (fade_time);

  unsigned int start_time = 500;

  // start at value = 100, t = start_time
  // will fade down to value = 0 at t = start_time + fade_time
  f.GetValue(100, start_time);

  // now go over the fade_time, set a new value (because it's bigger)
  start_time += 2.5 * fade_time;
  f.GetValue(50, start_time);

  SECTION("at t = 0") {
    double value = f.GetValue(0, start_time);
    REQUIRE(value == 50);
  }

  SECTION("at t = 1/4 * t0") {
    double value = f.GetValue(0, start_time + fade_time/4.0);
    REQUIRE(value == 7.0 / 8 * 50);
  }

  SECTION("at t = 1/2 * t0") {
    double value = f.GetValue(0, start_time + fade_time/2.0);
    REQUIRE(value == 25);
  }

  SECTION("at t = 3/4 * t0") {
    double value = f.GetValue(0, start_time + 3*fade_time/4.0);
    REQUIRE(value == 1.0 / 8 * 50);
  }

  SECTION("at t = t0") {
    double value = f.GetValue(0, start_time + fade_time);
    REQUIRE(value == 0);
  }

  SECTION("at t > t0") {
    double value = f.GetValue(0, start_time + fade_time * 2);
    REQUIRE(value == 0);
  }
}
