#pragma once

#include "modes/base_mode.hpp"
#include "Lights.h"
#include "NeoPixels.h"
#include "SoundSensor.h"
#include "fader.hpp"
#include <stdbool.h>
#include <vector>

namespace moodlight {

extern uint8_t serverGreen,serverRed,serverBlue, serverIntensity;
extern uint8_t serverSpinning;
extern Lights *lights;
extern Pixel color;
extern SoundSensor *sound;

class MusicMode : public BaseMode {
 public:
  MusicMode();
  ~MusicMode();
  void Run();

 private:
  volatile uint16_t bpm_ = 0;
  Pixel pix_[24];
  float res_[65];

  int last_update;

  void UpdateSoundValues();
  void CalculateIndividual();
  void CalculateAverage();
  double GetAverage();
  void SetAverage(double value);
  static void Spinning(Pixel * out, uint32_t index, uint32_t size, uintptr_t extra);
};

} // namespace
