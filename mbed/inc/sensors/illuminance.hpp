#pragma once

#include <stdint.h>
#include <stdbool.h>

namespace moodlight {
  
class Illuminance {
 public:
  /**
   * Does any required initialization for this service.
   */
  static bool Init();
  
  /**
   * Returns the current illuminance in lux.
   */
  static uint16_t Value();
};

} // namespace
