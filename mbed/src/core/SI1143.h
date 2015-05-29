/**
 * @author Guillermo A Torijano
 * 
 * @section LICENSE
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 * @section DESCRIPTION
 *
 * Parallax SI1143 Gesture Sensor.
 *
 * Datasheet:
 *
 * http://www.silabs.com/Support%20Documents/TechnicalDocs/Si114x.pdf
 */

#ifndef SI1143_h
#define SI1143_h

/**
 * Includes
 */

#include "mbed.h"

/**
 * Defines
 */

#define IR_ADDRESS                  0x5A
#define HW_KEY_VAL0                 0x17    //Value to write into the HW Key register

// Register Addresses

#define PART_ID                     0x00
#define REV_ID                      0x01
#define SEQ_ID                      0x02    //Si114x-A11 (MAJOR_SEQ=1, MINOR_SEQ=1)
#define INT_CFG                     0x03
#define IRQ_ENABLE                  0x04
#define IRQ_MODE1                   0x05
#define IRQ_MODE2                   0x06
#define HW_KEY                      0x07

#define MEAS_RATE                   0x08
#define ALS_RATE                    0x09
#define PS_RATE                     0x0A

#define ALS_LOW_TH0                 0x0B
#define ALS_LOW_TH1                 0x0C
#define ALS_HI_TH0                  0x0D
#define ALS_HI_TH1                  0x0E

#define PS_LED21                    0x0F
#define PS_LED3                     0x10

#define PS1_TH0                     0x11
#define PS1_TH1                     0x12
#define PS2_TH0                     0x13
#define PS2_TH1                     0x14
#define PS3_TH0                     0x15

#define PS3_TH1                     0x16
#define PARAM_WR                    0x17
#define COMMAND                     0x18

#define RESPONSE                    0x20
#define IRQ_STATUS                  0x21

#define ALS_VIS_DATA0               0x22
#define ALS_VIS_DATA1               0x23
#define ALS_IR_DATA0                0x24
#define ALS_IR_DATA1                0x25

#define PS1_DATA0                   0x26
#define PS1_DATA1                   0x27
#define PS2_DATA0                   0x28
#define PS2_DATA1                   0x29
#define PS3_DATA0                   0x2A
#define PS3_DATA1                   0x2B


#define AUX_DATA0                   0x2C
#define AUX_DATA1                   0x2D

#define PARAM_RD                    0x2E
#define CHIP_STAT                   0x30
#define ANA_IN_KEY                  0x3B

// Command Register Values

#define PARAM_QUERY                 0x80    //Value is ORed with Parameter Offset
#define PARAM_SET                   0xA0    //Value is ORed with Parameter Offset
#define PARAM_AND                   0xC0    //Value is ORed with Parameter Offset
#define PARAM_OR                    0xE0    //Value is ORed with Parameter Offset
#define NOP                         0x00
#define RESET                       0x01
#define BUSADDR                     0x02
#define PS_FORCE                    0x05
#define ALS_FORCE                   0x06
#define PSALS_FORCE                 0x07
#define PS_PAUSE                    0x09
#define ALS_PAUSE                   0x0A
#define PSALS_PAUSE                 0x0B
#define PS_AUTO                     0x0D
#define ALS_AUTO                    0x0E
#define PSALS_AUTO                  0x0F

// Ram Addresses

#define I2C_ADDR                    0x00
#define CHLIST                      0x01
#define PSLED12_SELECT              0x02  
#define PSLED3_SELECT               0x03
#define FILTER_EN                   0x04
#define PS_ENCODING                 0x05
#define ALS_ENCODING                0x06
#define PS1_ADCMUX                  0x07
#define PS2_ADCMUX                  0x08
#define PS3_ADCMUX                  0x09
#define PS_ADC_COUNTER              0x0A
#define PS_ADC_GAIN                 0x0B
#define PS_ADC_MISC                 0x0C
#define ALS1_ADCMUX                 0x0D
#define ALS2_ADCMUX                 0x0E
#define ALS3_ADCMUX                 0x0F
#define ALS_VIS_ADC_COUNTER         0x10
#define ALS_VIS_ADC_GAIN            0x11
#define ALS_VIS_ADC_MISC            0x12
#define ALS_HYST                    0x16
#define PS_HYST                     0x17
#define PS_HISTORY                  0x18
#define ALS_HISTORY                 0x19
#define ADC_OFFSET                  0x1A
#define SLEEP_CTRL                  0x1B
#define LED_REC                     0x1C
#define ALS_IR_ADC_COUNTER          0x1D
#define ALS_IR_ADC_GAIN             0x1E
#define ALS_IR_ADC_MISC             0x1F

// Measurement Channel List

#define PS1_TASK                    0x01
#define PS2_TASK                    0x02
#define PS3_TASK                    0x04
#define ALS_VIS_TASK                0x10
#define ALS_IR_TASK                 0x20
#define AUX_TASK                    0x40

/**
 * Parallax SI1143 Gesture Sensor.
 */
class SI1143
{
    public:
    
        /**
        * Constructor.
        *
        * @param sda mbed pin to use for SDA line of I2C interface.
        * @param scl mbed pin to use for SCL line of I2C interface.
        */
        SI1143(PinName sda, PinName scl);
        
        /**
         * Restarts the device.
         */
        void restart(void);
        
        /**
         * Creates a baseline for sampling measurements.
         * Should be done early in your code and after a reset.
         *
         * @param   ready Tells how many seconds to wait before getting samples from the device.
         * @param   repeat Tells how many samples to get from each leds on the device. Each repeat takes 12 ms.
         */
        void bias(int ready, int repeat);
        
        /**
         * Takes a number of samples from the proximity of led1 and returns a raw output.
         *
         * @param   repeat Tells how many samples to get from the device. Each sample takes 4 ms.
         * @return  In forced conversion output mode, will display a raw output of the average sample
         *          minus any baseline, where as the greater the value, the closer the object is to the device.
         */
        int get_ps1(int repeat);
        
        /**
         * Takes a number of samples from the proximity of led2 and returns a raw output.
         *
         * @param   repeat Tells how many samples to get from the device. Each sample takes 4 ms.
         * @return  In forced conversion output mode, will display a raw output of the average sample
         *          minus any baseline, where as the greater the value, the closer the object is to the device.
         */
        int get_ps2(int repeat);
        
        /**
         * Takes a number of samples from the proximity of led3 and returns a raw output.
         *
         * @param   repeat Tells how many samples to get from the device. Each sample takes 4 ms.
         * @return  In forced conversion output mode, will display a raw output of the average sample
         *          minus any baseline, where as the greater the value, the closer the object is to the device.
         */
        int get_ps3(int repeat);
        
        /**
         * Takes a number of samples for ambient light on device and returns a raw output.
         *
         * @param   repeat Tells how many samples to get from the device. Each sample takes 4 ms.
         * @return  In forced conversion output mode, will display a raw output of the average sample.
         */
        int get_vis(int repeat);
        
        /**
         * Takes a number of samples for infrared light on device and returns a raw output.
         *
         * @param   repeat Tells how many samples to get from the device. Each sample takes 4 ms.
         * @return  In forced conversion output mode, will display a raw output of the average sample.
         */
        int get_ir(int repeat);
        
        int get_aux(int repeat);

    private:
    
        I2C* i2c_;
        int bias1,bias2,bias3,PS1,PS2,PS3,VIS,IR;
        char LowB,HighB;
        
        /**
         * Wait for the device to respond, then send it a specific command.
         *
         * @param   cmd Command to send to the device. Read p20 of the datasheet for more details.
         */
        void command(char cmd);
        
        /**
         * Read a register from the device.
         *
         * @param   address Register to read from.
         * @param   num_data Bytes to read (always 1).
         * @return  Contents of register.
         */
        char read_reg(/*unsigned*/ char address, int num_data);
        
        /**
         * Write to a register on the device.
         *
         * @param   address Register to write to.
         * @param   num_data Data that is to be written.
         */
        void write_reg(char address, char num_data);
        
};

#endif
