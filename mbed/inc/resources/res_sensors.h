#ifndef RESSEN_H
#define RESSEN_H
 
#include "nsdl_support.h"

#include "mbed.h"
#include "rtos.h"
#include <stdio.h>

#include "PirSensor.h"
#include "SoundSensor.h"
#include "LightSensor.h"
#include "Temperature.h"

namespace moodlight {

int create_sensor_resources(sn_nsdl_resource_info_s *resource_ptr);
int get_illuminance();
int get_bpm();
int get_pir();
float get_temp();

}
#endif