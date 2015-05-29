#include "res_sensors.h"

#define LIGHT_RES_ID    "/sen/illuminance"
#define PIR_RES_ID    "/sen/motion"
#define BPM_RES_ID    "/sen/bpm"
#define TEMP_RES_ID   "/sen/temperature"

#define SEND_DELAY  4

namespace moodlight {

extern PirSensor *pir;
extern SoundSensor *sound;
extern LightSensor *lightSensor;
extern Temperature *temperature;

// Illuminance variables
static uint8_t ill_number = 0;
static uint8_t *ill_token_ptr = NULL;
static uint8_t ill_token_len = 0;

uint16_t illuminance_value = 0;
char illuminance_buff[5];

// PIR variables
static uint8_t pir_number = 0;
static uint8_t *pir_token_ptr = NULL;
static uint8_t pir_token_len = 0;

uint8_t pir_value = 0;
char pir_buff[2];

// BPM variables
static uint8_t bpm_number = 0;
static uint8_t *bpm_token_ptr = NULL;
static uint8_t bpm_token_len = 0;

uint8_t bpm_value = 0;
char bpm_buff[4];

// Temperature variables
static uint8_t temp_number = 0;
static uint8_t *temp_token_ptr = NULL;
static uint8_t temp_token_len = 0;

float temp_value = 0;
char temp_buff[6];

// Getting external values
int get_illuminance() {
  if (lightSensor) {
    return lightSensor->GetValue();
  }
  return 0;
}

int get_bpm() {
  if (sound) {
    return sound->GetBPM();
  }
  return 0;
}

int get_pir() {
  if (pir) {
    return pir->GetValue();
  }
  return 0;
}

float get_temp() {
  if (temperature) {
    return temperature->GetValue();
  }
  return 0;
}

// Notification sending thred, sending rate is defined by SEND_DELAY
static void sensors_send_thread(void const *args) {
  int32_t time = 0;
  while (true) {
    Thread::wait(500);
    time++;
    sn_nsdl_exec(time);
    // Send illuminance
    if(!(time % SEND_DELAY) && ill_number != 0 && ill_token_ptr != NULL) {
      ill_number++;
      
      illuminance_value = get_illuminance();
      sprintf(illuminance_buff, "%u", illuminance_value);
      
      if(sn_nsdl_send_observation_notification(ill_token_ptr, ill_token_len, (uint8_t*)illuminance_buff, strlen(illuminance_buff), &ill_number, 1, COAP_MSG_TYPE_NON_CONFIRMABLE, 0) == 0) {
          //Send failed
      }
      else {
          //Send okay
      }
    }
    // Send PIR
    if(!(time % SEND_DELAY) && pir_number != 0 && pir_token_ptr != NULL) {
      pir_number++;
      
      pir_value = get_pir();
      sprintf(pir_buff, "%u", pir_value);
      
      if(sn_nsdl_send_observation_notification(pir_token_ptr, pir_token_len, (uint8_t*)pir_buff, strlen(pir_buff), &pir_number, 1, COAP_MSG_TYPE_NON_CONFIRMABLE, 0) == 0) {
          //Send failed
      }
      else {
          //Send okay
      }
    }
    // Send BPM
    if(!(time % SEND_DELAY) && bpm_number != 0 && bpm_token_ptr != NULL) {
      bpm_number++;
      
      bpm_value = get_bpm();
      sprintf(bpm_buff, "%u", bpm_value);
      
      if(sn_nsdl_send_observation_notification(bpm_token_ptr, bpm_token_len, (uint8_t*)bpm_buff, strlen(bpm_buff), &bpm_number, 1, COAP_MSG_TYPE_NON_CONFIRMABLE, 0) == 0) {
          //Send failed
      }
      else {
          //Send okay
      }
    }
    // Send temperature
    if(!(time % SEND_DELAY) && temp_number != 0 && temp_token_ptr != NULL) {
    	temp_number++;

    	temp_value = get_temp();
      sprintf(temp_buff, "%0.2f", temp_value);

      if(sn_nsdl_send_observation_notification(temp_token_ptr, temp_token_len, (uint8_t*)temp_buff, strlen(temp_buff), &temp_number, 1, COAP_MSG_TYPE_NON_CONFIRMABLE, 0) == 0) {
          //Send failed
      }
      else {
          //Send okay
      }
    }
  }
}

// Illuminance callback, GET allowed
static uint8_t light_resource_cb(sn_coap_hdr_s *received_coap_ptr, sn_nsdl_addr_s *address, sn_proto_info_s * proto) {
  sn_coap_hdr_s *coap_res_ptr = 0;
  coap_res_ptr = sn_coap_build_response(received_coap_ptr, COAP_MSG_CODE_RESPONSE_CONTENT);
  
  illuminance_value = get_illuminance();
  sprintf(illuminance_buff, "%u", illuminance_value);
  
  coap_res_ptr->payload_len = strlen(illuminance_buff);
  coap_res_ptr->payload_ptr = (uint8_t*)illuminance_buff;
  if(received_coap_ptr->token_ptr) {
    if(ill_token_ptr) {
      free(ill_token_ptr);
      ill_token_ptr = 0;
    }
    ill_token_ptr = (uint8_t*)malloc(received_coap_ptr->token_len);
    if(ill_token_ptr) {
      memcpy(ill_token_ptr, received_coap_ptr->token_ptr, received_coap_ptr->token_len);
      ill_token_len = received_coap_ptr->token_len;
    }
  }
  if(received_coap_ptr->options_list_ptr->observe) {
    coap_res_ptr->options_list_ptr = (sn_coap_options_list_s*)malloc(sizeof(sn_coap_options_list_s));
    memset(coap_res_ptr->options_list_ptr, 0, sizeof(sn_coap_options_list_s));
    coap_res_ptr->options_list_ptr->observe_ptr = &ill_number;
    coap_res_ptr->options_list_ptr->observe_len = 1;
    ill_number++;
  }
  sn_nsdl_send_coap_message(address, coap_res_ptr);
  coap_res_ptr->options_list_ptr->observe_ptr = 0;
  sn_coap_parser_release_allocated_coap_msg_mem(coap_res_ptr);
  return 0;
}
 
// PIR callback, GET allowed
static uint8_t pir_resource_cb(sn_coap_hdr_s *received_coap_ptr, sn_nsdl_addr_s *address, sn_proto_info_s * proto) {
  sn_coap_hdr_s *coap_res_ptr = 0;
  coap_res_ptr = sn_coap_build_response(received_coap_ptr, COAP_MSG_CODE_RESPONSE_CONTENT);
  
  pir_value = get_pir();
  sprintf(pir_buff, "%u", pir_value);
  
  coap_res_ptr->payload_len = strlen(pir_buff);
  coap_res_ptr->payload_ptr = (uint8_t*)pir_buff;
  if(received_coap_ptr->token_ptr) {
    if(pir_token_ptr) {
      free(pir_token_ptr);
      pir_token_ptr = 0;
    }
    pir_token_ptr = (uint8_t*)malloc(received_coap_ptr->token_len);
    if(pir_token_ptr) {
      memcpy(pir_token_ptr, received_coap_ptr->token_ptr, received_coap_ptr->token_len);
      pir_token_len = received_coap_ptr->token_len;
    }
  }
  if(received_coap_ptr->options_list_ptr->observe) {
    coap_res_ptr->options_list_ptr = (sn_coap_options_list_s*)malloc(sizeof(sn_coap_options_list_s));
    memset(coap_res_ptr->options_list_ptr, 0, sizeof(sn_coap_options_list_s));
    coap_res_ptr->options_list_ptr->observe_ptr = &pir_number;
    coap_res_ptr->options_list_ptr->observe_len = 1;
    pir_number++;
  }
  sn_nsdl_send_coap_message(address, coap_res_ptr);
  coap_res_ptr->options_list_ptr->observe_ptr = 0;
  sn_coap_parser_release_allocated_coap_msg_mem(coap_res_ptr);
  return 0;
}
 
// BPM callback, GET allowed
static uint8_t bpm_resource_cb(sn_coap_hdr_s *received_coap_ptr, sn_nsdl_addr_s *address, sn_proto_info_s * proto) {
  sn_coap_hdr_s *coap_res_ptr = 0;
  coap_res_ptr = sn_coap_build_response(received_coap_ptr, COAP_MSG_CODE_RESPONSE_CONTENT);
  
  bpm_value = get_bpm();
  sprintf(bpm_buff, "%u", bpm_value);
  
  coap_res_ptr->payload_len = strlen(bpm_buff);
  coap_res_ptr->payload_ptr = (uint8_t*)bpm_buff;
  if(received_coap_ptr->token_ptr) {
    if(bpm_token_ptr) {
      free(bpm_token_ptr);
      bpm_token_ptr = 0;
    }
    bpm_token_ptr = (uint8_t*)malloc(received_coap_ptr->token_len);
    if(bpm_token_ptr) {
      memcpy(bpm_token_ptr, received_coap_ptr->token_ptr, received_coap_ptr->token_len);
      bpm_token_len = received_coap_ptr->token_len;
    }
  }
  if(received_coap_ptr->options_list_ptr->observe) {
    coap_res_ptr->options_list_ptr = (sn_coap_options_list_s*)malloc(sizeof(sn_coap_options_list_s));
    memset(coap_res_ptr->options_list_ptr, 0, sizeof(sn_coap_options_list_s));
    coap_res_ptr->options_list_ptr->observe_ptr = &bpm_number;
    coap_res_ptr->options_list_ptr->observe_len = 1;
    bpm_number++;
  }
  sn_nsdl_send_coap_message(address, coap_res_ptr);
  coap_res_ptr->options_list_ptr->observe_ptr = 0;
  sn_coap_parser_release_allocated_coap_msg_mem(coap_res_ptr);
  return 0;
}

// temperature callback, GET allowed
static uint8_t temperature_resource_cb(sn_coap_hdr_s *received_coap_ptr, sn_nsdl_addr_s *address, sn_proto_info_s * proto) {
  sn_coap_hdr_s *coap_res_ptr = 0;
  coap_res_ptr = sn_coap_build_response(received_coap_ptr, COAP_MSG_CODE_RESPONSE_CONTENT);
  
  temp_value = get_temp();
  sprintf(temp_buff, "%0.2f", temp_value);
  
  coap_res_ptr->payload_len = strlen(temp_buff);
  coap_res_ptr->payload_ptr = (uint8_t*)temp_buff;
  if(received_coap_ptr->token_ptr) {
    if(temp_token_ptr) {
      free(temp_token_ptr);
      temp_token_ptr = 0;
    }
    temp_token_ptr = (uint8_t*)malloc(received_coap_ptr->token_len);
    if(temp_token_ptr) {
      memcpy(temp_token_ptr, received_coap_ptr->token_ptr, received_coap_ptr->token_len);
      temp_token_len = received_coap_ptr->token_len;
    }
  }
  if(received_coap_ptr->options_list_ptr->observe) {
    coap_res_ptr->options_list_ptr = (sn_coap_options_list_s*)malloc(sizeof(sn_coap_options_list_s));
    memset(coap_res_ptr->options_list_ptr, 0, sizeof(sn_coap_options_list_s));
    coap_res_ptr->options_list_ptr->observe_ptr = &temp_number;
    coap_res_ptr->options_list_ptr->observe_len = 1;
    temp_number++;
  }
  sn_nsdl_send_coap_message(address, coap_res_ptr);
  coap_res_ptr->options_list_ptr->observe_ptr = 0;
  sn_coap_parser_release_allocated_coap_msg_mem(coap_res_ptr);
  return 0;
}

int create_sensor_resources(sn_nsdl_resource_info_s *resource_ptr) {
  // Thread to send sensor values
  static Thread sensors_thread(sensors_send_thread);
  
  nsdl_create_dynamic_resource(resource_ptr,
      sizeof(LIGHT_RES_ID)-1,
      (uint8_t*)LIGHT_RES_ID,
      0,
      0,
      1,
      &light_resource_cb,
      SN_GRS_GET_ALLOWED);
  
  nsdl_create_dynamic_resource(resource_ptr,
      sizeof(PIR_RES_ID)-1,
      (uint8_t*)PIR_RES_ID,
      0,
      0,
      1,
      &pir_resource_cb,
      SN_GRS_GET_ALLOWED);
  
  nsdl_create_dynamic_resource(resource_ptr,
      sizeof(BPM_RES_ID)-1,
      (uint8_t*)BPM_RES_ID,
      0,
      0,
      1,
      &bpm_resource_cb,
      SN_GRS_GET_ALLOWED);
  

  nsdl_create_dynamic_resource(resource_ptr,
      sizeof(TEMP_RES_ID)-1,
      (uint8_t*)TEMP_RES_ID,
      0,
      0,
      1,
      &temperature_resource_cb,
      SN_GRS_GET_ALLOWED);

  
  return 0;
}
}
