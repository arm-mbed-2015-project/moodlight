/*
 * SoundSensor.cpp
 *
 *  Created on: 21 апр. 2015 г.
 *      Author: niellune
 */

#include "SoundSensor.h"

namespace moodlight
{
	//Serial pc(USBTX, USBRX);

	void SoundSensor::ReadCycle(void const *args)
	{
		SoundSensor *sensor = (SoundSensor*)args;

		while(sensor->_working)
		{
			SoundSensor::ReadData(sensor); // 19us
			wait_us(30);
			// 49us total. 20400Hz.
		}
	}

	void SoundSensor::ReadData(SoundSensor *sensor)
	{
		if(sensor->_pointer%sensor->_fft==0)
		{
			// skip data if not processed
			if(!sensor->_processed)
			{
				return;
			}

			// true - 1 ready, false - 2 ready;
			sensor->_partition = !sensor->_partition;
			sensor->_ready = true;
			sensor->_processed = false;

			// round buffer
			if(sensor->_pointer==sensor->_fft*2)
			{
				sensor->_pointer = 0;
			}
		}

		// read sensor data
		sensor->_buffer[sensor->_pointer++] = (sensor->_sensor->read_u16()-32768.0)/32768.0;
	}

	void SoundSensor::Processor(void const *args)
	{
		SoundSensor *sensor = (SoundSensor*)args;

		while(sensor->_working)
		{
			if(!sensor->_ready)
			{
				Thread::wait(1);
			}
			else
			{
				sensor->_ready = false;

				//process
				sensor->_hartley->Transform(sensor->_buffer, sensor->_result, sensor->_partition? 0 : sensor->_fft);

				sensor->_processed = true;

				if(!sensor->_reading_flux)
				{

					// new bpm
					for(uint8_t i=0; i<(sensor->_fft+1)/4; i++)
					{
						sensor->_flux[sensor->_flux_point] = 0;
						float delta = sensor->_result[i] - sensor->_last_values[i];
						if(delta>0)
						{
							sensor->_flux[sensor->_flux_point] = sensor->_flux[sensor->_flux_point] + delta;
						}
						sensor->_last_values[i] = sensor->_result[i];
					}

					//pc.printf("\r\n %f", 10*sensor->_flux[sensor->_flux_point]);

					if(sensor->_bpm_cycle<FLUXLINES)
						sensor->_bpm_cycle++;

					sensor->_flux_point++;
					if(sensor->_flux_point>=FLUXLINES)
						sensor->_flux_point = 0;
				}
			}
		}
	}

	SoundSensor::SoundSensor(PinName pin, uint8_t fft)
	{
		_fft = fft;
		_buffer = (float*)malloc(fft*2*sizeof(float));
		_result = (float*)malloc(sizeof(float)*(fft+1)/2);
		_ready = false;
		_processed = true;
		_partition = false;
		_pointer = 1;
		_sensor = new AnalogIn(pin);
		_working = true;
	    _hartley = new Hartley(_fft);
	    _reading_flux = false;

	    _smothbpm = (uint8_t*)malloc(sizeof(uint8_t)*BPMSMOOTH);
	    _flux = (float*)malloc(sizeof(float)*FLUXLINES);
	    _last_values = (float*)malloc(sizeof(float)*(fft+1)/2);
	    _bpm = 0;
	    _bpm_cycle = 0;
	    _bmp_pointer = 0;
	    _flux_point = 0;

		// Start processor
	    new Thread(ReadCycle, this);
		new Thread(Processor, this);
	}

	void SoundSensor::GetValue(float* buffer)
	{
		for(uint8_t i=0; i<_fft/2; i++)
		{
			buffer[i] = _result[i];
		}
	}

	uint16_t SoundSensor::GetBPM()
	{
		if(_bpm_cycle<FLUXLINES)
			return _bpm;

		_reading_flux = true;
		_bpm_cycle = 0;
		uint16_t max = 0;
		float maxv = 0;
		for(int lines = 60; lines<180; lines++)
		{
			float maxsum = 0;
			for(int delta = 1; delta<lines; delta++)
			{
				float sum = 0;
				uint8_t count = 0;
				for(int i = delta; i<FLUXLINES; i=i+lines)
				{
					count++;
					sum = sum+_flux[(_flux_point+i)%FLUXLINES];
				}
				sum = sum*sum/(count);
				if(sum>maxsum)
					maxsum = sum;
			}
			if(maxsum>maxv)
			{
				maxv = maxsum;
				max = lines;
			}
		}
		_reading_flux = false;

		uint8_t bpm = (uint8_t)(60.0/(max*0.006272));


		_smothbpm[_bmp_pointer++] = bpm;
		if(_bmp_pointer>BPMSMOOTH)
			_bmp_pointer = 0;

		float avg = 0;
		for(uint8_t i=0; i<BPMSMOOTH; i++)
		{
			avg += _smothbpm[i];
		}
		avg = avg/BPMSMOOTH;

		_bpm = avg;

		//pc.printf("\r\n lines %d bpm %d", max, bpm);

		return _bpm;
	}

	SoundSensor::~SoundSensor()
	{
		_working = false;
		_hartley->~Hartley();
		free(_buffer);
		free(_result);
		free(_last_values);
		free(_smothbpm);
		free(_flux);
	}

} /* namespace moodsensor */
