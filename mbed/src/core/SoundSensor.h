/*
 * SoundSensor.h
 *
 *  Created on: 21 апр. 2015 г.
 *      Author: niellune
 */

#ifndef CORE_SOUNDSENSOR_H_
#define CORE_SOUNDSENSOR_H_

#include "mbed.h"
#include "rtos.h"
#include "Hartley.h"

namespace moodlight
{

#define BPMSMOOTH 5
#define FLUXLINES 1024

class SoundSensor
{
public:
	/*
	 * Constructor
	 * INPUT pin - pin where microphone is connected
	 * INPUT fft - fft size. Recommended 128
	 */
	SoundSensor(PinName pin, uint8_t fft = 128);

	/*
	 * Get current levels on several frequences
	 * Buffer must be (fft/2+1). Low frequences are closer to 0. Levels are numbers 0-1.
	 * Greater the number is, louder the sound on this frequency is.
	 * INPUT/OUTPUT buffer - sets the buffer where results will be provided
	 */
	void GetValue(float* buffer);

	/*
	 * Returns current BPM
	 * OUT bpm
	 */
	uint16_t GetBPM();

	/*
	 * CleanUp
	 */
	~SoundSensor();

private:
	volatile bool _ready;
	volatile bool _partition;
	volatile bool _processed;
	uint16_t _pointer;
	AnalogIn *_sensor;

	float *_buffer;
	uint8_t _fft;

	Hartley* _hartley;
	bool _working;
	float *_result;

	uint8_t *_smothbpm;
	uint8_t _bmp_pointer;

	float *_flux;
	float *_last_values;
	uint16_t _flux_point;
	volatile bool _reading_flux;
	volatile uint16_t _bpm_cycle;
	uint8_t _bpm;

	static void ReadCycle(void const *args);
	static void ReadData(SoundSensor *sensor);
	static void Processor(void const *args);
};

} /* namespace moodsensor */

#endif /* CORE_SOUNDSENSOR_H_ */
