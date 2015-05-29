#include <stdio.h>

#include "connection.h"

extern Serial pc;
extern EthernetInterface eth;
extern Endpoint nsp;
extern UDPSocket server;

extern char endpoint_name[16];
extern uint8_t ep_type[];
extern uint8_t lifetime_ptr[];

namespace moodlight {

bool Connection::init() {
  // Initialize ethernet connection
  ethernet_init();
  
  // Initialize NSP node (UDP)
  nsp_init();
  
  // Initialize NSDL stack
  nsdl_init();
  // Create NSDL resources
  create_resources();
  return 1;
}

void Connection::run() {
  // Run the NSDL event loop (never returns)
  nsdl_event_loop();
}

bool Connection::ethernet_init() {
  // Use DHCP
  if (eth.init() != 0) {
    pc.printf("Ethernet initialization failed!\n");
    return 0;
  }
  if (eth.connect() != 0) {
    pc.printf("Ethernet connection failed!\n");
    return 0;
  }
  pc.printf("IP Address is %s\n", eth.getIPAddress());
  return 1;
}

bool Connection::nsp_init() {
  // Start listening UDP port
  if (server.bind(NSP_PORT) != 0) {
    pc.printf("UDP port bind failed!\n");
    return 0;
  }

  // Define endpoint address and port
  if (nsp.set_address(NSP_ADDRESS, NSP_PORT) != 0) {
    pc.printf("Endpoint address setting failed!\n");
    return 0;
  }
  
  pc.printf("NSP=%s - port %d\n", NSP_ADDRESS, NSP_PORT);
  pc.printf("EP name:%s\n", endpoint_name);
  
  return 1;
}

int Connection::create_resources() {
  sn_nsdl_resource_info_s *resource_ptr = NULL;
  sn_nsdl_ep_parameters_s *endpoint_ptr = NULL;
  
  pc.printf("Creating resources");
  
  // Create resources
  resource_ptr = (sn_nsdl_resource_info_s*)nsdl_alloc(sizeof(sn_nsdl_resource_info_s));
  if(!resource_ptr)
    return 0;
  memset(resource_ptr, 0, sizeof(sn_nsdl_resource_info_s));

  resource_ptr->resource_parameters_ptr = (sn_nsdl_resource_parameters_s*)nsdl_alloc(sizeof(sn_nsdl_resource_parameters_s));
  if(!resource_ptr->resource_parameters_ptr) {
    nsdl_free(resource_ptr);
    return 0;
  }
  memset(resource_ptr->resource_parameters_ptr, 0, sizeof(sn_nsdl_resource_parameters_s));

  // Static resources
  nsdl_create_static_resource(resource_ptr, sizeof("dev/mfg")-1, (uint8_t*) "dev/mfg", 0, 0,  (uint8_t*) "Sensinode", sizeof("Sensinode")-1);
  nsdl_create_static_resource(resource_ptr, sizeof("dev/mdl")-1, (uint8_t*) "dev/mdl", 0, 0,  (uint8_t*) "NSDL-C mbed device", sizeof("NSDL-C mbed device")-1);
  
  // Dynamic resources
  create_color_resources(resource_ptr);
  create_mode_resource(resource_ptr);
  create_sensor_resources(resource_ptr);
  create_spinning_resource(resource_ptr);

  // Register with NSP
  endpoint_ptr = nsdl_init_register_endpoint(endpoint_ptr, (uint8_t*)endpoint_name, ep_type, lifetime_ptr);
  if(sn_nsdl_register_endpoint(endpoint_ptr) != 0) {
    pc.printf("NSP registering failed\r\n");
  }
  else {
    pc.printf("NSP registering OK\r\n");
  }
  nsdl_clean_register_endpoint(&endpoint_ptr);

  nsdl_free(resource_ptr->resource_parameters_ptr);
  nsdl_free(resource_ptr);
  return 1;
}

}