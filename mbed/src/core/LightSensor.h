/*
 * LightSensor.h
 *
 *  Created on: 21 апр. 2015 г.
 *      Author: niellune
 */

#ifndef CORE_LIGHTSENSOR_H_
#define CORE_LIGHTSENSOR_H_

#include "mbed.h"
#include "SI1143.h"

namespace moodlight
{

/*
 * Provide information from light sensor
 */
class LightSensor
{

public:
	/*
	 * Constructor
	 * INPUT sda, scl - sda and scl pins where light sensor is connected
	 */
	LightSensor(PinName sda, PinName scl);

	/*
	 * Get current light
	 */
	int GetValue();

private:
	SI1143 _sensor;
};

} /* namespace moodsensor */

#endif /* CORE_LIGHTSENSOR_H_ */
