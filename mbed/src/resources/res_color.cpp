#include <stdlib.h>
#include "mbed.h"
#include "nsdl_support.h"
#include "res_color.h"

#define COLOR_RES_ID    "/led_color"

namespace moodlight {

extern uint8_t serverGreen,serverRed,serverBlue, serverIntensity;

// Color callback
static uint8_t color_resource_cb(sn_coap_hdr_s *received_coap_ptr, sn_nsdl_addr_s *address, sn_proto_info_s * proto) {
  sn_coap_hdr_s *coap_res_ptr = 0;
  static uint32_t colors_value = 0;
  char color_buff[10];
  
  // GET request
  if(received_coap_ptr->msg_code == COAP_MSG_CODE_REQUEST_GET) {
    coap_res_ptr = sn_coap_build_response(received_coap_ptr, COAP_MSG_CODE_RESPONSE_CONTENT);
    // Combine color values to one message
    colors_value = serverIntensity;
    colors_value += serverBlue << 8;
    colors_value += serverGreen << 16;
    colors_value += serverRed << 24;
    sprintf(color_buff, "%i", colors_value);
    
    coap_res_ptr->payload_len = strlen(color_buff);
    coap_res_ptr->payload_ptr = (uint8_t*)color_buff;
    sn_nsdl_send_coap_message(address, coap_res_ptr);
  }
  
  // PUT request
  else if(received_coap_ptr->msg_code == COAP_MSG_CODE_REQUEST_PUT) {
    memcpy(color_buff, (char *)received_coap_ptr->payload_ptr, received_coap_ptr->payload_len);
    color_buff[received_coap_ptr->payload_len] = '\0';
    
    // Convert characters to numbers
    colors_value = atol(color_buff);
    
    // Parse values from colors_value
    serverIntensity = colors_value;
    serverBlue = colors_value >> 8;
    serverGreen = colors_value >> 16;
    serverRed = colors_value >> 24;
    
    coap_res_ptr = sn_coap_build_response(received_coap_ptr, COAP_MSG_CODE_RESPONSE_CHANGED);
    sn_nsdl_send_coap_message(address, coap_res_ptr);
  }
  
  sn_coap_parser_release_allocated_coap_msg_mem(coap_res_ptr);
  return 0;
}

int create_color_resources(sn_nsdl_resource_info_s *resource_ptr) {
  nsdl_create_dynamic_resource(resource_ptr,
      sizeof(COLOR_RES_ID)-1,
      (uint8_t*)COLOR_RES_ID,
      0,
      0,
      0,
      &color_resource_cb,
      SN_GRS_GET_ALLOWED | SN_GRS_PUT_ALLOWED);
  
  return 0;
}
}