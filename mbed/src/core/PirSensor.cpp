/*
 * PirSensor.cpp
 *
 *  Created on: 20 марта 2015 г.
 *      Author: niellune
 */

#include "PirSensor.h"

namespace moodlight
{

	PirSensor::PirSensor(PinName pin) : _input(pin, PullDown)
	{
		_timer = new Timer();
		_timer->start();
	}

	bool PirSensor::GetValue()
	{
		if(_input.read()>0)
		{
			_timer->reset();
		}

		return _timer->read_ms()<5000;
	}

} /* namespace moodsensor */
