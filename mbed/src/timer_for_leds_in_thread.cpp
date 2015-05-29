#include "timer_for_leds_in_thread.hpp"
#include "leds/leds.hpp"
#include "rtos.h"
#include "sensors/microphone.hpp"
#include "mbed.h"

namespace bpmstuff{

int running=1;
void led2_thread(void const *args) {

	int bpm=120;
	//Moodlight::Microphone.BPM();
  //gives delay between beats
  int bpmWaitTime=(1000/bpm);
  while (running) {
    moodlight::LedsState s = { 0 };
    
    //set leds light up according to bpm
    s.r = 255;
    s.g = 255;
    s.b = 0;
    s.transition_ms=0;
    moodlight::Leds::Set(s);
    
    Thread::wait(bpmWaitTime/2);
    s.r = 0;
    s.g = 0;
    s.b = 0;
    
    moodlight::Leds::Set(s);

    Thread::wait(bpmWaitTime/2);
  }
}

void led2_thread_register(){
  Thread thread(led2_thread);
}

void led2_thread_destroy(){
  running=0;
}

} //namespace

