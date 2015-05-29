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

#include "SI1143.h"
#include <stdio.h>

SI1143::SI1143(PinName sda, PinName scl)
{
    wait_ms(30);
    i2c_ = new I2C(sda, scl);
    // 3.4MHz, as specified by the datasheet, but DO NOT USE.
    //i2c_->frequency(3400000);
    
    restart();
}

void SI1143::restart()
{
    command(RESET);
    wait_ms(30);
    
    // Setting up LED Power to full
    write_reg(HW_KEY,HW_KEY_VAL0);
    write_reg(PS_LED21,0xAA);
    write_reg(PS_LED3,0x0A);
    write_reg(MEAS_RATE, 0X00);
    write_reg(ALS_RATE, 0X00);
    write_reg(PS_RATE, 0X00);
    write_reg(PARAM_WR, AUX_TASK + ALS_IR_TASK + ALS_VIS_TASK + PS1_TASK + PS2_TASK + PS3_TASK);
    
    command(PARAM_SET + (CHLIST & 0x1F));

    write_reg(INT_CFG,0);
    write_reg(IRQ_ENABLE,0);
    write_reg(IRQ_MODE1,0);
    write_reg(IRQ_MODE2,0);
}

void SI1143::command(char cmd)
{
    int val;
    
    val = read_reg(RESPONSE,1);
    while(val!=0)
    {
        write_reg(COMMAND,NOP);
        val = read_reg(RESPONSE,1);
    }
    do{
        write_reg(COMMAND,cmd);
        if(cmd==RESET) break;
        val = read_reg(RESPONSE,1);
    }while(val==0);
}

char SI1143::read_reg(/*unsigned*/ char address, int num_data)
{
    unsigned char chip_addr = IR_ADDRESS << 1;
    char rx;

    i2c_->write(chip_addr, &address, num_data, true);
    i2c_->read(chip_addr | 1, &rx, num_data);
    wait_ms(1);
    
    return rx;
}

void SI1143::write_reg(char address, char num_data) // Write a resigter
{  
    unsigned char chip_addr = IR_ADDRESS << 1;
    char tx[2];
    
    tx[0] = address;
    tx[1] = num_data;
    i2c_->write(chip_addr, tx, 2);
    wait_ms(1);
}

void SI1143::bias(int ready, int repeat)
{
	bias1 = 0;
	bias2 = 0;
	bias3 = 0;
    wait(ready);
    bias1 = get_ps1(repeat);
    bias2 = get_ps2(repeat);
    bias3 = get_ps3(repeat);
}

int SI1143::get_ps1(int repeat) // Read the data for the first LED
{
    int stack = 0;
    
    command(PS_FORCE);
    
    for(int r=repeat; r>0; r=r-1)
    {
        LowB = read_reg(PS1_DATA0,1);
        HighB = read_reg(PS1_DATA1,1);
        stack = stack + (HighB * 256) + LowB;
    }
    PS1 = stack / repeat;
    
    if(PS1 > bias1)
        PS1 = PS1 - bias1;
    else
        PS1 = 0;
    
    return PS1;
}

int SI1143::get_ps2(int repeat) // Read the data for the second LED
{
    int stack = 0;
    
    command(PS_FORCE);
    
    for(int r=repeat; r>0; r=r-1)
    {
        LowB = read_reg(PS2_DATA0,1);
        HighB = read_reg(PS2_DATA1,1);
        stack = stack + (HighB * 256) + LowB;
    }
    PS2 = stack / repeat;
    
    if(PS2 > bias2)
        PS2 = PS2 - bias2;
    else
        PS2 = 0;
    
    return PS2;
}

int SI1143::get_ps3(int repeat) // Read the data for the third LED
{
    int stack = 0;
    
    command(PS_FORCE);
    
    for(int r=repeat; r>0; r=r-1)
    {
        LowB = read_reg(PS3_DATA0,1);
        HighB = read_reg(PS3_DATA1,1);
        stack = stack + (HighB * 256) + LowB;
    }
    PS3 = stack / repeat;
    
    if(PS3 > bias3)
        PS3 = PS3 - bias3;
    else
        PS3 = 0;
    
    return PS3;
}

int SI1143::get_vis(int repeat) // Read the data for ambient light
{
    int stack = 0;
    
    command(ALS_FORCE);
    //command(ALS_AUTO);
    
    for(int r=repeat; r>0; r=r-1)
    {
        LowB = read_reg(ALS_VIS_DATA0,1);
        HighB = read_reg(ALS_VIS_DATA1,1);
        stack += (HighB * 256) + LowB;
    }
    VIS = stack / repeat;
    
    return VIS;
}

int SI1143::get_ir(int repeat) // Read the data for infrared light
{
    int stack = 0;
    
    command(ALS_FORCE);
    //command(ALS_AUTO);
    
    for(int r=repeat; r>0; r=r-1)
    {
        LowB = read_reg(ALS_IR_DATA0,1);
        HighB = read_reg(ALS_IR_DATA1,1);
        stack += (HighB * 256) + LowB;
    }
    IR = stack / repeat;
    
    return IR;
}


int SI1143::get_aux(int repeat) // Read the data for infrared light
{
    int stack = 0;

    command(ALS_FORCE);
    //command(ALS_AUTO);

    for(int r=repeat; r>0; r=r-1)
    {
        LowB = read_reg(AUX_DATA0,1);
        HighB = read_reg(AUX_DATA1,1);
        IR = stack + (HighB * 256) + LowB;
    }
    IR = stack / repeat;

    return IR;
}
