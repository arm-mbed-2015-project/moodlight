#pragma once

namespace bpmstuff{
void led2_thread(void const *args);
void led2_thread_register(void);
void led2_thread_destroy(void);
}