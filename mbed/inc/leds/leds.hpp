#pragma once

#include <stdint.h>
#include <stdbool.h>

namespace moodlight {

struct LedsState {
  uint8_t r;              // Red value [0, 255].
  uint8_t g;              // Green value [0, 255].
  uint8_t b;              // Blue value [0, 255].
  uint32_t transition_ms; // Time in milliseconds it should take for the new 
                          // color to show. Can be 0.
};

class Leds {
 public:
  /**
   * Does any required initialization for this service.
   */
  static bool Init();
  
  /**
   * Sets the LED colors.
   * 
   * @param state The new state of the leds.
   * @return success Whether the operation was successful.
   */
  static bool Set(LedsState const &state);
};

} // namespace
