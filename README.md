# Moodlight

The system adjusts the lighting (color and intensity) based on different information: weather, lighting sensor, day of time. Also can listen to ambient sound and adjust lighting based on music that is playing (getting beats per minute for classifying type of music that is playing).

# Installation & Use

Check the `README.md` files in each of the subdirectories to see how to install and use the different components.

## Platform

- [FRDM-K64F](http://developer.mbed.org/platforms/FRDM-K64F/) (256K RAM)

## Inputs

- Light sensor
    + [I2C sensor](http://developer.mbed.org/components/Si1143-GestureProximityAmbient-Light-inf/)
    + Connected to I2C SDA at D14, I2C SCL at D15, ground and 3.3 V
- Microphone
    + [Sparkfun MEMs microphone](https://www.sparkfun.com/products/9868)
    + ground, 3.3 V, A0
- PIR 
    + [Digikey PIR](http://www.digikey.com/product-detail/en/555-28027/555-28027-ND/1774435)
    + ground, 3.3 V, D5
- Temperature
    + [LM35](http://www.ti.com/lit/ds/symlink/lm35.pdf)
    + ground, 3.3 V, A2

## Outputs

- RGB LEDs
    + [LED ring](http://www.adafruit.com/product/1586) ([Adafruit NeoPixels](http://developer.mbed.org/users/vnessie/notebook/neopixel-led-chain-using-high-speed-spi/))
    + SPI at D11, ground, 5 V
    + NOTE: You may need to add another extra LED (ws2812) before the LED ring, otherwise the color of the first LED in the ring may be incorrect
