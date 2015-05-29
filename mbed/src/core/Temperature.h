/*
 * Temperature.h
 *
 *  Created on: 27 мая 2015 г.
 *      Author: niellune
 */

#ifndef SRC_CORE_TEMPERATURE_H_
#define SRC_CORE_TEMPERATURE_H_

#include "mbed.h"

namespace moodlight
{

class Temperature
{
public:
	Temperature(PinName pin);
	float GetValue();

private:
    AnalogIn *temp_sensor;
};

}

#endif /* SRC_CORE_TEMPERATURE_H_ */
