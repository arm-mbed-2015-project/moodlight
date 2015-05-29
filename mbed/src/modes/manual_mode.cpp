#include "modes/manual_mode.hpp"
#include "leds/leds.hpp"

namespace moodlight {

float ManualMode::lvl = 1;
int ManualMode::rnd1 = 10, ManualMode::rnd2 = 20;

ManualMode::ManualMode(){
	mred = 90;
	mgreen = 50;
	mblue = 255;
	intensity = 100;
	motion = 0;
	k = 0;
}
ManualMode::~ManualMode() {}

void ManualMode::Spinning(Pixel * out, uint32_t index, uint32_t size,
                          uintptr_t extra) {

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

void ManualMode::FancySpin(Pixel * out, uint32_t index, uint32_t size, uintptr_t extra) {

    int delta = extra%24 - index;
    if(delta<0)
        delta+=24;
    int br = 255-10*delta;
    if(br<0)
        br = 0;

    int b = br-abs((int)(255-extra%500));
    int r = br-abs((int)(255-(extra*7+rnd1)%500));
    int g = br-abs((int)(255-(extra*3+rnd2)%500));

    out->blue = b<0?0:b/lvl;
    out->red   = r<0?0:r/lvl;
    out->green = g<0?0:g/lvl;

}

void ManualMode::Run(){

  bool changed_values = mred != serverRed || mblue != serverBlue
                     || mgreen != serverGreen || intensity != serverIntensity
                     || spinning != serverSpinning;


  if(k++>1000)
  {
	  k = 1;
	  rnd1 = rand()%200;
	  rnd2 = rand()%200;
  }

  if(k%10==0)
  {
	  if(pir->GetValue())
	  {
		  lvl = lvl/1.1;
		  if(lvl<1)
			lvl = 1;
	  }
	  else
	  {
		  lvl = lvl*1.1;
		  if(lvl>3)
			lvl = 3;
	  }
  }

  if (!changed_values) return;

  //get current values given by server
  mred = serverRed;
  mblue = serverBlue;
  mgreen = serverGreen;
  intensity = serverIntensity;

  uint8_t already_spinning = spinning;
  spinning = serverSpinning;

  double factor = intensity / 255.0;

  color.red = (uint8_t)(mred * factor);
  color.green = (uint8_t)(mgreen * factor);
  color.blue = (uint8_t)(mblue * factor);



  pc.printf("local  %d %d %d\r\n", color.red, color.green, color.blue);
  pc.printf("spinning %d, already_spinning %d\n", spinning, already_spinning);

  if (spinning>0 && spinning!=already_spinning) {
      if(spinning==1)
    	  lights->setGenerator(Spinning);
      if(spinning==2)
    	  lights->setGenerator(FancySpin);
  }

  else {
    lights->setColor(color.red, color.green, color.blue);
  }
}

}
