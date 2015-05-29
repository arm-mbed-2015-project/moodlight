#include "modes/weather_light_motion_mode.hpp"
#include "leds/leds.hpp"
#include <stdbool.h>
#include "Lights.h"
#include "NeoPixels.h"

#include "mbed.h"
extern Serial pc;

namespace moodlight {

WeatherLightMotionMode::WeatherLightMotionMode(){
	motion = false;
	intensity = 500;
	temperature = 20;
}
WeatherLightMotionMode::~WeatherLightMotionMode(){

}

void WeatherLightMotionMode::Spinning(Pixel * out, uint32_t index,
                                      uint32_t size, uintptr_t extra) {

    int delta = extra%24 - index;

    if(delta<0)
        delta+=24;
    
    int br = 255 - 20*delta;
    
    if(br<0)
        br = 0;

    out->blue = (color.blue/255.0)*br;
    out->red   = (color.red/255.0)*br;
    out->green = (color.green/255.0)*br;
}


void WeatherLightMotionMode::Run(){
  wait(1);
  bool already_spinning = motion;

  if (pir)
    motion = pir->GetValue();

  if (lightSensor)
    intensity = lightSensor->GetValue();
  
  
  
  float intensityFactor = sqrt(intensity)/40;
  if(intensityFactor>1)
	  intensityFactor = 1;
  if(intensityFactor<0.2)
	  intensityFactor = 0.2;

	  //blue light scaled with intensity
	color.red = (uint8_t) (serverRed*intensityFactor);
	color.green = (uint8_t) (serverGreen*intensityFactor);
	color.blue = (uint8_t) (serverBlue*intensityFactor);

  if(motion == false){
	  lights->setColor(color.red,color.green,color.blue);
  }else{
	  //call generator
    if(!already_spinning)
	  lights->setGenerator(Spinning);
  }
return;
}

} //namespace
