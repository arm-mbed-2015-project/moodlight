#pragma once

#include <stdint.h>
#include <stdbool.h>

namespace moodlight {

class Motion {
 public:
  /**
   * Does any required initialization for this service.
   */
  static bool Init();

  /**
   * Returns true when motion has been detected.
   */
  static bool Active();
};

} // namespace
