#pragma once
#include "leds/leds.hpp"

namespace moodlight {

class BaseMode {
 public:
  
  virtual ~BaseMode() {};
  /**
   * Runs the logic for this mode. Basically, gets sensor values and sets
   * the state of the LEDs based on that.
   */
  virtual void Run() = 0;
};

} // namespace
