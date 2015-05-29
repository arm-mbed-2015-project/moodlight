/*
 * Temperature.cpp
 *
 *  Created on: 27 мая 2015 г.
 *      Author: niellune
 */

#include "Temperature.h"

namespace moodlight
{

Temperature::Temperature(PinName pin)
{
	temp_sensor = new AnalogIn(pin);
}

float Temperature::GetValue()
{
	return temp_sensor->read()*3.3*100;
}

} /* namespace moodsensor */
