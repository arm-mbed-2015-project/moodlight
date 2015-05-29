#include "modes/music_mode.hpp"
#include "leds/leds.hpp"

#include "Timer.h"
#include <stdio.h>

#define NUM_LEDS (24)
#define HIGH_BPM_THRESHOLD (90)
#define MAX_INTENSITY (255)

namespace moodlight {

extern Timer g_timer;

MusicMode::MusicMode(){

}

MusicMode::~MusicMode(){

}

void MusicMode::Run(){

  UpdateSoundValues();
  CalculateIndividual();

  lights->SetPixels(pix_, NUM_LEDS, true);
}

void MusicMode::UpdateSoundValues() {
  sound->GetValue(res_);

  if(last_update++>100)
  {
	  last_update = 0;
	  bpm_ = sound->GetBPM();
  }

}

void MusicMode::CalculateIndividual() {
  for (int i = 0; i < NUM_LEDS; i++) {
    pix_[i].green = 0;
    pix_[i].blue = 0;
    pix_[i].red = 0;

    uint16_t value = res_[i] * MAX_INTENSITY;
    if(value>MAX_INTENSITY)
    	value = MAX_INTENSITY;

    if(bpm_<60)
    {
        pix_[i].green = 0;
        pix_[i].blue = 0;
        pix_[i].red = value;
    }
    else if(bpm_<70)
    {
        pix_[i].green = value;
        pix_[i].blue = 0;
        pix_[i].red = value;
    }
    else if(bpm_<80)
    {
        pix_[i].green = value;
        pix_[i].blue = 0;
        pix_[i].red = 0;
    }
    else if(bpm_<90)
    {
        pix_[i].green = value;
        pix_[i].blue = value;
        pix_[i].red = 0;
    }
    else
    {
        pix_[i].green = value;
        pix_[i].blue = value;
        pix_[i].red = value;
    }
  }
}

void MusicMode::CalculateAverage() {
  double value = GetAverage();
  SetAverage(value);
}

double MusicMode::GetAverage() {
  double total = 0;

  for (int i = 0; i < NUM_LEDS; i++) {
    total += res_[i];
  }

  return total / NUM_LEDS * MAX_INTENSITY;
}

void MusicMode::SetAverage(double value) {
  for (int i = 0; i < NUM_LEDS; i++) {
    pix_[i].green = 0;
    pix_[i].blue = 0;
    pix_[i].red = 0;

    if (bpm_ > HIGH_BPM_THRESHOLD)
      pix_[i].green = value;
    else
      pix_[i].blue = value;
  }
}

} //namespace
