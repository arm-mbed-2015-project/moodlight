#pragma once

#include <stdint.h>
#include <stdbool.h>

namespace moodlight {

class Microphone {
 public:
  /**
   * Does any required initialization for this service.
   */
  static bool Init();

  /**
   * Returns the current amplitude in the range [-1, 1].
   */
  static float Amplitude();

  /**
   * Returns the current BPM.
   */
  static uint16_t BPM();
};

} // namespace
