#pragma once

#include <stdbool.h>

#include "mbed.h"
#include "rtos.h"
#include "EthernetInterface.h"
#include "nsdl_support.h"
#include "res_color.h"
#include "res_mode.h"
#include "res_sensors.h"
#include "res_spinning.h"

extern const char* NSP_ADDRESS;
extern const int NSP_PORT;

namespace moodlight {

class Connection {
  public:
    bool init();
    void run();
  private:
    bool ethernet_init();
    bool nsp_init();
    int create_resources();
};

}