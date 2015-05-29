#pragma once

#include <stdbool.h>
#include "leds/leds.hpp"
#include "modes/base_mode.hpp"

namespace moodlight {

enum ModeEnum {
  MODE_MANUAL,
  MODE_MUSIC,
  MODE_WEATHER_LIGHT_MOTION
};

class ModeController {
 public:
  /**
   * Does any required initialization for this service.
   */
  static bool Init();

  /**
   * Runs the logic for the current mode. 
   */
  static void Run();

  /**
   * Returns the current mode.
   */
  static ModeEnum Get(); 

  /**
   * Sets the current mode. If setting the mode to manual, you can add a second
   * argument that specifies the state of the leds.
   *
   * @param mode The mode to set.
   * @optional state The state to set for the leds. Ignored unless mode is 
   *                 set to manual.
   */
  static bool Set(char new_mode);
  static bool Set(ModeEnum new_mode);
  static bool Set(ModeEnum new_mode, LedsState const &state);

  /**
   * Resets the service to its defaults. Which would mean that the mode is 
   * set back to manual.
   */
  static void Reset();
  
 private:
  static ModeEnum mode_enum_;
  static BaseMode *mode_;
};

} // namespace
