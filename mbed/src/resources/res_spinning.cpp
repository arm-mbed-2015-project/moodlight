#include <string.h>
#include "mbed.h"
#include "nsdl_support.h"
#include "res_spinning.h"

#define SPINNING_RES_ID    "/led_spinning"

namespace moodlight {

extern uint8_t serverSpinning;

// GET and PUT allowed
static uint8_t spinning_resource_cb(sn_coap_hdr_s *received_coap_ptr, sn_nsdl_addr_s *address, sn_proto_info_s * proto) {
  sn_coap_hdr_s *coap_res_ptr = 0;
  static uint8_t spinning_state = '0';
  
  // GET request
  if(received_coap_ptr->msg_code == COAP_MSG_CODE_REQUEST_GET) {
    coap_res_ptr = sn_coap_build_response(received_coap_ptr, COAP_MSG_CODE_RESPONSE_CONTENT);
    coap_res_ptr->payload_len = 1;
    coap_res_ptr->payload_ptr = &spinning_state;
    sn_nsdl_send_coap_message(address, coap_res_ptr);
  }
  
  // PUT request
  else if(received_coap_ptr->msg_code == COAP_MSG_CODE_REQUEST_PUT) {
    if(received_coap_ptr->payload_len) {
        if (received_coap_ptr->payload_ptr[0] == '2') {
          serverSpinning = 2;
          spinning_state = '2';
        }
      // Enable spinning
        else if (received_coap_ptr->payload_ptr[0] == '1') {
        serverSpinning = 1;
        spinning_state = '1';
      }
      // Disable spinning
      else {
        serverSpinning = 0;
        spinning_state = '0';
      }
      coap_res_ptr = sn_coap_build_response(received_coap_ptr, COAP_MSG_CODE_RESPONSE_CHANGED);
      sn_nsdl_send_coap_message(address, coap_res_ptr);
    }
  }
  
  sn_coap_parser_release_allocated_coap_msg_mem(coap_res_ptr);
  return 0;
}

int create_spinning_resource(sn_nsdl_resource_info_s *resource_ptr) {
  nsdl_create_dynamic_resource(resource_ptr,
      sizeof(SPINNING_RES_ID)-1,
      (uint8_t*)SPINNING_RES_ID,
      0,
      0,
      0,
      &spinning_resource_cb,
      SN_GRS_GET_ALLOWED | SN_GRS_PUT_ALLOWED);
  
  return 0;
}
}
