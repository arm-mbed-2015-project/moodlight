#include "mbed.h"
#include "Lights.h"
#include "DigitalIn.h"
#include "rtos.h"
#include "Hartley.h"
#include "SI1143.h"
#include "PirSensor.h"
#include "SoundSensor.h"

DigitalOut led_red(LED_RED);
DigitalOut led_green(LED_GREEN);
DigitalOut led_blue(LED_BLUE);
DigitalIn sw2(SW2);
DigitalIn sw3(SW3);
Serial pc(USBTX, USBRX);

float volatile lvl = 1;

int rnd1, rnd2;
int ount = 0;

using namespace moodlight;



void loading(Pixel * out, uint32_t index, uint32_t size, uintptr_t extra) {

    int delta = extra%24 - index;
    if(delta<0)
        delta+=24;
    int br = 50-10*delta;
    if(br<0)
        br = 0;

    out->blue = 0;
    out->red   = br;
    out->green = 0;

}

void generate(Pixel * out, uint32_t index, uint32_t size, uintptr_t extra) {

    int delta = extra%24 - index;
    if(delta<0)
        delta+=24;
    int br = 255-10*delta;
    if(br<0)
        br = 0;

    int b = br-abs((int)(255-extra%500));
    int r = br-abs((int)(255-(extra*7+rnd1)%500));
    int g = br-abs((int)(255-(extra*3+rnd2)%500));

    out->blue = b<0?0:b/lvl;
    out->red   = r<0?0:r/lvl;
    out->green = g<0?0:g/lvl;

}

void sound(void const *args)
{
    DigitalOut led_blue(LED_BLUE);
    NeoPixels* l = new NeoPixels(D11);
    AnalogIn analog_sensor(A0);

    led_blue = 0;

    int fft = 128;

    Hartley* h = new Hartley(fft);
    float buff[fft];
    float res[fft/2];
    float lght[16];
    Pixel pix[20];

    while(true)
    {
        led_blue = 0;
        for(int i=0; i<fft; i++)
        {
            // 15us reading from sensor
            buff[i] = (analog_sensor.read_u16()-32768.0)/32768.0;
            wait_us(30);
            ount++;
        }

        h->Transform(buff, res);
        for(int i=0; i<16; i++)
        {
            lght[i] = 0;
            for(int j=0; j<fft/32; j++)
            {
                lght[i] += res[i*4+j];
            }
            //pc.printf("\r%f %f %f %f %f %f %f %f", lght[0], lght[1], lght[2], lght[3], lght[4], lght[5], lght[6], lght[7]);
        }

        for(int i=0; i<16; i++)
        {
            pix[i].green = (uint8_t)(lght[i]*100);
            pix[i].blue = 0;
            pix[i].red = 0;
        }

        l->update(pix, 17);
        Thread::wait(0);
    }
}

int main()
{
	// Set transfer rate
    pc.baud(9600);
    pc.printf("Hello World from FRDM-K64F board.\r\n");

    led_blue = 1;
    led_green = 1;
    led_red = 0;

    // Create a temporary DigitalIn so we can configure the pull-down resistor.
    // (The mbed API doesn't provide any other way to do this.)
    // An alternative is to connect an external pull-down resistor.
    DigitalIn(D11, PullDown);

    //new Thread(sound, NULL, osPriorityNormal);
    //new Thread(proxy, NULL);

    // create lights
    Lights* l = new Lights(D11, 24);
    PirSensor* pir = new PirSensor(D5);
    int k = 0;
    uint32_t offset = 0;


    SoundSensor *sound = new SoundSensor(A0);
    pc.printf("created.\r\n");
    l->active = false;
    int cc = 0;
    while(true)
    {
        led_green = !led_green;
        float res[(129)/2];
        float lght[16];
        Pixel pix[16];

        sound->GetValue(res);

        if(cc++%100==0)
        {
        	sound->GetBPM();
        }

        for(int i=0; i<16; i++)
        {
            lght[i] = 0;
            for(int j=0; j<128/32; j++)
            {
                lght[i] += res[i*4+j];
            }
        }

        for(int i=0; i<16; i++)
        {
            pix[i].green = (uint8_t)(lght[i]*100);
            pix[i].blue = 0;
            pix[i].red = 0;
        }

        l->update(pix, 16);
        Thread::wait(10);
    }

    // Wait for pir init
    while(offset++<33*40)
    {
        wait(0.03);
        if(!pir->GetValue())
        {
            offset+=4000;
        }
    }

    l->setGenerator(generate);
    AnalogIn temp_sensor(A1);

    while (true) {

    	float temp = temp_sensor.read();
        pc.printf("\r temp %f          ", temp*3.3*100);


        if(pir->GetValue())
        {
        	// People around
            led_red = 1;
            led_green = 1;
            led_blue = 0;
            lvl = lvl-1;
            if(lvl<1)
              lvl = 1;
        }
        else
        {
        	// Nobody
            led_red = 0;
            led_green = 0;
            led_blue = 1;
            lvl = lvl+1;
            if(lvl>1)
              lvl = 1;
        }



        if(++k%15>7)
        {
            l->setColor( rand()%256/lvl, rand()%256/lvl, rand()%256/lvl);
        }
        else
        {
            if(k%15==0)
            {
                rnd1 = rand()%200;
                rnd2 = rand()%200;
                l->setGenerator(generate);
            }
        }

        led_green = !led_green;

        wait(3);
    }
}

