#include "mbed.h"

#include "connection.h"

Serial pc(USBTX, USBRX);
EthernetInterface eth;
Endpoint nsp;
UDPSocket server;

char endpoint_name[16] = "node-002";
uint8_t ep_type[] = {"moodlight"};
uint8_t lifetime_ptr[] = {"1200"};

using namespace moodlight;
Connection conn;

int main() {
  pc.printf("Start\n");
  conn.init();
  pc.printf("END\n");
  conn.run();
}