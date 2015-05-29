#include "NeoPixels.h"

namespace moodlight
{
	NeoPixels::NeoPixels(PinName out) : _spi(out, NC, NC)
	{
	    _spi.format(12, 3);
	    _spi.frequency(2400000);
	}

    void NeoPixels::update(Pixel buffer[], uint32_t length)
    {
    	__disable_irq();
        for (size_t i = 0; i < length; i++) {
            pixel(buffer[i]);
        }
        __enable_irq();
    }

    void NeoPixels::update(PixelGenerator generator, uint32_t length, uintptr_t extra)
    {
        Pixel out;
        for (size_t i = 0; i < length; i++) {
            generator(&out, i, length, extra);
            pixel(out);
        }
    }

    void NeoPixels::pixel(Pixel& pixel)
    {
    	writeBits(pixel.green >> 4);
    	writeBits(pixel.green);
    	writeBits(pixel.red >> 4);
    	writeBits(pixel.red);
    	writeBits(pixel.blue >> 4);
    	writeBits(pixel.blue);
    }

    void NeoPixels::writeBits(uint8_t b)
    {
    	//0b010010010010 = 1170
    	_spi.write(1170 | ((b&1)+((b&2)<<2)+((b&4)<<4)+((b&8)<<6)));
    }
};

