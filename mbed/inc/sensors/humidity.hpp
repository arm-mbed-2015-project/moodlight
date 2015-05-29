#pragma once

#include <stdint.h>
#include <stdbool.h>

namespace moodlight {

class Humidity {
 public:
  /**
   * Does any required initialization for this service.
   */
  static bool Init();
  
  /**
   * Returns the current relative humidity as a percentage. Range [0, 100].
   */
  static uint8_t Value();
};

} // namespace
