#pragma once

#include <stdbool.h>

namespace moodlight {

class Temperature {
 public:
  /**
   * Does any required initialization for this service.
   */
  static bool Init();

  /**
   * Returns the current temperature in celcius.
   */
  static float Value();
};

} // namespace
