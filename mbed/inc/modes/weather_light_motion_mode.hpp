#pragma once

#include "modes/base_mode.hpp"
#include "Lights.h"
#include <stdbool.h>
#include "NeoPixels.h"

#include "PirSensor.h"
#include "SoundSensor.h"
#include "LightSensor.h"

namespace moodlight {

extern uint8_t serverGreen,serverRed,serverBlue, serverIntensity;
extern uint8_t serverSpinning;
extern Lights *lights;
extern Pixel color;
extern PirSensor *pir;
extern SoundSensor *sound;
extern LightSensor *lightSensor;

class WeatherLightMotionMode : public BaseMode {
	bool motion;
	float intensity;
	float temperature;

 public:
  WeatherLightMotionMode();
  ~WeatherLightMotionMode();
  void Run();
  //static Pixel color;

private:
  static void Spinning(Pixel * out, uint32_t index, uint32_t size, uintptr_t extra);



};

} // namespace
