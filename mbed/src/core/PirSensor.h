/*
 * PirSensor.h
 *
 *  Created on: 20 марта 2015 г.
 *      Author: niellune
 */

#ifndef PIRSENSOR_H_
#define PIRSENSOR_H_

#include "mbed.h"

namespace moodlight
{

/*
 * Provide information from pir sensor
 */
class PirSensor
{
public:
	/*
	 * Constructor
	 * INPUT pin - data pin where sensor is connected
	 */
	PirSensor(PinName pin);

	/*
	 * Get current value
	 * OUTPUT - true if pir is active (sensing people), false othervise
	 */
	bool GetValue();

private:
	DigitalIn _input;
	Timer *_timer;
};

} /* namespace moodsensor */

#endif /* PIRSENSOR_H_ */
