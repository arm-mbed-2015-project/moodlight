#include <stdbool.h>

#include "mbed.h"
#include "Timer.h"
#include "mode_controller.hpp"
#include "leds/leds.hpp"
#include "rtos.h"
#include "timer_for_leds_in_thread.hpp"
#include "Lights.h"
#include "NeoPixels.h"
#include "connection.h"
#include "Hartley.h"
#include "SI1143.h"
#include "PirSensor.h"
#include "SoundSensor.h"
#include "LightSensor.h"
#include "Temperature.h"
#include "main.h"

Serial pc(USBTX, USBRX);
EthernetInterface eth;
Endpoint nsp;
UDPSocket server;

char endpoint_name[16] = "node-003";
uint8_t ep_type[] = {"moodlight"};
uint8_t lifetime_ptr[] = {"1200"};

const char* NSP_ADDRESS = NSP_SERVER_ADRESS;
const int NSP_PORT = 5683;

namespace moodlight {

uint8_t serverGreen = 160;
uint8_t serverBlue = 150;
uint8_t serverRed = 255;
uint8_t serverIntensity = 100;
uint8_t serverSpinning = 0;
Pixel color;
Lights *lights;

PirSensor *pir;
SoundSensor *sound;
LightSensor *lightSensor;
Temperature *temperature;

Timer g_timer;

} // namespace

using namespace moodlight;

Connection conn;

void run_connection(void const *args) {
  conn.run();
}

int main() {
  g_timer.start();
  pc.baud(PC_BAUD_RATE);

  lights = new Lights(D11, 24);
  pir = new PirSensor(D5);
  sound = new SoundSensor(A0, 128);
  lightSensor = new LightSensor(D14, D15);
  temperature = new Temperature(A2);

  pc.printf("Init\n");
  conn.init();
  pc.printf("Init set\n");

  ModeController::Init();

  Thread device_server_thread(run_connection);
  pc.printf("Running\n");

  while (true) {
    ModeController::Run();
    Thread::wait(10);
  }
}

// int main() {
//   g_timer.start();
//   pc.baud(115200);

//   lightSensor = new LightSensor(D14, D15);
//   pc.printf("Running\n");

//   while (true) {
//     int val = lightSensor->GetValue();
//     printf("ligth value %d\n", val);
//     Thread::wait(1000);
//   }
// }
