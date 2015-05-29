#ifndef CORE_LIGHTS_H_
#define CORE_LIGHTS_H_

#include "mbed.h"
#include "rtos.h"
#include "NeoPixels.h"

namespace moodlight
{

/*
 * Works with neo pixels
 */
class Lights : public NeoPixels
{

#define LED_DEFAULT_WAIT 25

public:
	/*
	 * Constructor
	 * INPUT out - name of the SPI pin where leds are connected
	 * INPUT size - number of leds
	 */
	Lights(PinName out, int size);

	/*
	 * Smoothly change color to selected. Stops generator if it was set.
	 * INPUT R, G, B - rgb value of color
	 */
	void setColor(uint8_t R, uint8_t G, uint8_t B);

	/*
	 * Start updating pixels using generator
	 * INPUT generator - generator function
	 */
	void setGenerator(PixelGenerator generator);

	/*
	 * Set pixels color directly. if length less than size, other pixels will be set to 0
	 * INPUT buffer - array of pixel colors
	 * INPUT length - length of buffer
	 * INPUT fast - go straight to upper values
	 * INPUT wait - timeout between updates
	 */
	void SetPixels(Pixel buffer[], uint32_t length, bool fast);

	/*
	 * Destructor
	 */
	~Lights();

private:
	bool doupdate();
	static void updateCycle(const void *lights);
	bool adjustPixel(Pixel* source, Pixel* target, uint8_t fade_speed);

	Thread *_thread;
	Pixel *_current;
	Pixel *_target;

	volatile bool _running;
	PixelGenerator _generator;
	uint8_t _size;
    uint8_t _fade_speed;
	uint16_t _extra;

	volatile bool _useGenerator;
	volatile bool _generatorReady;
	volatile bool _force;
};

} /* namespace moodsensor */

#endif /* CORE_LIGHTS_H_ */
