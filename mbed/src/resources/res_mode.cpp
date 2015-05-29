#include "mbed.h"
#include "nsdl_support.h"
#include "res_mode.h"
#include "mode_controller.hpp"

#define MODE_RES_ID    "/mode"

namespace moodlight {

// GET and PUT allowed
static uint8_t mode_resource_cb(sn_coap_hdr_s *received_coap_ptr, sn_nsdl_addr_s *address, sn_proto_info_s * proto) {
  sn_coap_hdr_s *coap_res_ptr = 0;
  static uint8_t mode_selected = '0';
  
  // GET request
  if(received_coap_ptr->msg_code == COAP_MSG_CODE_REQUEST_GET) {
    coap_res_ptr = sn_coap_build_response(received_coap_ptr, COAP_MSG_CODE_RESPONSE_CONTENT);

    coap_res_ptr->payload_len = 1;
    coap_res_ptr->payload_ptr = &mode_selected;
    sn_nsdl_send_coap_message(address, coap_res_ptr);
  }
  
  // PUT request
  else if(received_coap_ptr->msg_code == COAP_MSG_CODE_REQUEST_PUT) {
    if(received_coap_ptr->payload_len) {
      char mode = received_coap_ptr->payload_ptr[0];
      
      // Incorrect mode default to 0
      if (mode < '0' || mode > '2') {
        mode = 0;
      }
      
      mode_selected = mode;
      
      ModeController::Set(mode);
      
      coap_res_ptr = sn_coap_build_response(
          received_coap_ptr, 
          COAP_MSG_CODE_RESPONSE_CHANGED);
      
      sn_nsdl_send_coap_message(address, coap_res_ptr);
    }
  }
  
  sn_coap_parser_release_allocated_coap_msg_mem(coap_res_ptr);
  
  return 0;
}

int create_mode_resource(sn_nsdl_resource_info_s *resource_ptr) {
  nsdl_create_dynamic_resource(resource_ptr, 
      sizeof(MODE_RES_ID)-1, 
      (uint8_t*)MODE_RES_ID, 
      0, 
      0, 
      0, 
      &mode_resource_cb, 
      SN_GRS_GET_ALLOWED | SN_GRS_PUT_ALLOWED);
  
  return 0;
}
}