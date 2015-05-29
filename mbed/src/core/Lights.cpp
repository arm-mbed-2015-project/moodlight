#include "Lights.h"

namespace moodlight
{
	uint8_t adjust(uint8_t source, uint8_t target, uint8_t fade_speed)
	{
		int delta = target - source;
		if(delta>0)
		{
			return delta<fade_speed ? source+delta : source+fade_speed;
		}
		else
		{
			return delta>-fade_speed ? source+delta : source-fade_speed;
		}
	}

	void loading(Pixel * out, uint32_t index, uint32_t size, uintptr_t extra) {
		int delta = extra%size - index;
		if(delta<0)	delta+=size;
		int br = 200-20*delta;
		if(br<0) br = 0;
		out->blue =  br*0.8;
		out->red   = 0;
		out->green = br*0.8;
	}

	Lights::Lights(PinName out, int size) : NeoPixels(out)
	{
		_generator = loading;
		_force = true;
		_fade_speed = 1;
		_useGenerator = true;
		_generatorReady = true;
		_extra = 0;
		_size = size;
		_running = true;
		_current = (Pixel*)malloc(size*sizeof(Pixel));
		_target = (Pixel*)malloc(size*sizeof(Pixel));
		_thread = new Thread(updateCycle, this);
	}

	void Lights::SetPixels(Pixel buffer[], uint32_t length, bool fast)
	{
		_useGenerator = false;
		_generatorReady = false;
		_fade_speed = 20;
		_force = fast;

		for(uint8_t i=0; i<_size; i++)
		{
			if(i<length)
			{
				_target[i].blue = gamma[buffer[i].blue];
				_target[i].red = gamma[buffer[i].red];
				_target[i].green = gamma[buffer[i].green];

				if(fast&&_target[i].blue>_current[i].blue)
					_current[i].blue = _target[i].blue;
				if(fast&&_target[i].red>_current[i].red)
					_current[i].red = _target[i].red;
				if(fast&&_target[i].green>_current[i].green)
					_current[i].green = _target[i].green;
			}
			else
			{
				_target[i].blue = 0;
				_target[i].red = 0;
				_target[i].green = 0;
			}
		}
	}

	void Lights::setColor(uint8_t r, uint8_t g, uint8_t b)
	{
		_force = false;
		_fade_speed = 1;
		_useGenerator = false;
		_generatorReady = false;

		for(int i = 0; i<_size; i++)
		{
			_target[i].blue = gamma[b];
			_target[i].red = gamma[r];
			_target[i].green = gamma[g];
		}
	}

	void Lights::setGenerator(PixelGenerator generator)
	{
		_force = false;
		setColor(0,0,0);
		_fade_speed = 10;
		_generator = generator;
		_useGenerator = true;
	}

	bool Lights::adjustPixel(Pixel* source, Pixel* target, uint8_t fade_speed)
	{
		bool result = true;
		if(source->blue!=target->blue)
		{
			source->blue = adjust(source->blue, target->blue, fade_speed);
			result = false;
		}
		if(source->red!=target->red)
		{
			source->red = adjust(source->red, target->red, fade_speed);
			result = false;
		}
		if(source->green!=target->green)
		{
			source->green = adjust(source->green, target->green, fade_speed);
			result = false;
		}
		return result;
	}

	Lights::~Lights()
	{
		_running = false;
		_thread->wait(100);
		_thread->terminate();
		free(_current);
		free(_target);
	}

	bool Lights::doupdate()
	{
		if(_generatorReady)
		{
			Pixel out;
			for(size_t i=0; i<_size; i++)
			{
				_generator(&out, i, _size, _extra);
				_current[i].blue = gamma[out.blue];
				_current[i].green = gamma[out.green];
				_current[i].red = gamma[out.red];
			}
			_extra++;
			update(_current, _size);
			return false;
		}
		else
		{
			bool result = true;
			for(size_t i=0; i<_size; i++)
			{
				result = result & adjustPixel(&_current[i], &_target[i], _fade_speed);
			}
			if(!result)
			{
				update(_current, _size);
			}
			else
			{
				if(_useGenerator)
					_generatorReady = true;
			}
			return result;
		}
	}

	void Lights::updateCycle(const void *task)
	{
		Lights *lights = (Lights*)task;
		while(lights->_running)
		{
			if(lights->doupdate()&&!lights->_force)
			{
				Thread::wait(500);
			}
			else
			{
				Thread::wait(LED_DEFAULT_WAIT);
			}
		}
	}

} /* namespace moodsensor */
