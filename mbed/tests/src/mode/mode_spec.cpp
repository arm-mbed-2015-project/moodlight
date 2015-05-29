#define CATCH_CONFIG_MAIN
#include "catch.hpp"
#include "mode.hpp"

using namespace moodlight;

TEST_CASE("modes can be set") {
  Mode::Reset();

  SECTION("mode is manual by default") {
    REQUIRE(Mode::Get() == MODE_MANUAL);
  }

  SECTION("setting the mode changes it") {
    Mode::Set(MODE_SOUND_BPM);

    REQUIRE(Mode::Get() == MODE_SOUND_BPM);
  }
}
