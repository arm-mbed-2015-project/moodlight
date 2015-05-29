#include <stdio.h>
#include <stdlib.h>


#include "mode_controller.hpp"
#include "leds/leds.hpp"
#include "modes/manual_mode.hpp"
#include "modes/music_mode.hpp"
#include "modes/weather_light_motion_mode.hpp"

#include "mbed.h"

//required for to get rid of warnings in eclipse
#ifndef NULL
#define NULL   ((void *) 0)
#endif


namespace moodlight {

ModeEnum ModeController::mode_enum_ = MODE_MANUAL;
BaseMode *ModeController::mode_ = NULL;

bool ModeController::Init() {
  ModeController::Reset();
  return true;
}

void ModeController::Run() {
  if (mode_) {
    mode_->Run();
  }
}

ModeEnum ModeController::Get() {
  return mode_enum_;
}

bool ModeController::Set(char new_mode) {
  int m = new_mode - '0';
  return ModeController::Set((ModeEnum) m);
}

bool ModeController::Set(ModeEnum new_mode) {
  printf("ModeController::Set %d\r\n", new_mode);

  mode_enum_ = new_mode;

  if (mode_) {
    delete mode_;
    mode_ = NULL;
  }
  //testing
  if (mode_!=NULL) {
    delete mode_;
    mode_ = NULL;
  }
  
  switch (new_mode) {
    case MODE_MANUAL:
      mode_ = new ManualMode();
      break;

    case MODE_MUSIC:
      mode_ = new MusicMode();
      break;

    case MODE_WEATHER_LIGHT_MOTION:
      mode_ = new WeatherLightMotionMode();
      break;

    default:
      pc.printf("Unknown mode, defaulting to manual.\n");
      mode_ = new ManualMode();
      break;
  }

  return true;
}

bool ModeController::Set(ModeEnum new_mode, LedsState const &state) {
  return ModeController::Set(new_mode) && Leds::Set(state);
}

void ModeController::Reset() {
  ModeController::Set(MODE_MANUAL);
}

} // namespace moodlight
