#pragma once

#include "modes/base_mode.hpp"
#include "Lights.h"
#include <stdbool.h>
#include "NeoPixels.h"
#include "PirSensor.h"

extern Serial pc;

namespace moodlight {

extern uint8_t serverGreen,serverRed,serverBlue, serverIntensity;
extern uint8_t serverSpinning;
extern Lights *lights;
extern PirSensor *pir;
extern Pixel color;

/**
 * This class implements device side of behevior for server controll.
 * All values come from the server.
 */
class ManualMode : public BaseMode {
 public:
  ManualMode();
  ~ManualMode();
  void Run();

 private:
  uint8_t mred, mgreen, mblue;
  uint8_t intensity;
  bool motion;
  uint8_t spinning;
  uint16_t k;

  static float lvl;
  static int rnd1, rnd2;

  static void FancySpin(Pixel * out, uint32_t index, uint32_t size, uintptr_t extra);
  static void Spinning(Pixel * out, uint32_t index, uint32_t size, uintptr_t extra);
};

} // namespace
