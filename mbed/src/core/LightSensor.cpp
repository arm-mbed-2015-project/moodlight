/*
 * LightSensor.cpp
 *
 *  Created on: 21 апр. 2015 г.
 *      Author: niellune
 */

#include "LightSensor.h"

namespace moodlight
{

	LightSensor::LightSensor(PinName sda, PinName scl) : _sensor(sda, scl)
	{
		_sensor.bias(1, 10);
	}

	int LightSensor::GetValue()
	{
		return _sensor.get_vis(1);
	}

} /* namespace moodsensor */
