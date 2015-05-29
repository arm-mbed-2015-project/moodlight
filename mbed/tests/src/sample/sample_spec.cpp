#define CATCH_CONFIG_MAIN
#include "catch.hpp"

#include "sample.hpp"

TEST_CASE("sample class works") {
  Sample s(5);
  REQUIRE(s.number == 5);

  SECTION("another one") {
    Sample s2(10);
    REQUIRE(s2.number == 10);
  }
}
