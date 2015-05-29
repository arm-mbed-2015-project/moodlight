#include "fader.hpp"

namespace moodlight {

Fader::Fader(unsigned int fade_time_ms) {
  fade_time_ms_ = fade_time_ms;
  highest_value_ = 0;
  highest_at_ms_ = 0;
}

Fader::~Fader() {}

void Fader::SetFadeTime(unsigned int fade_time_ms) {
  fade_time_ms_ = fade_time_ms;
}

double Fader::GetValue(double current_value, unsigned int current_time_ms) {
  double faded_value = GetFadedValue(current_time_ms);

  if (current_value >= faded_value) {
    highest_value_ = current_value;
    highest_at_ms_ = current_time_ms;
    return current_value;
  }

  return faded_value;
}

double Fader::GetFadedValue(unsigned int current_time_ms) {
  double t0 = 0;
  double t1 = fade_time_ms_;
  double a = 2.0 / (t1 * t1);

  double attenuation;
  double t = current_time_ms - highest_at_ms_;

  if (t < t0) {
    attenuation = 0;
  }

  else if (t <= 0.5 * t1) {
    attenuation = a * t * t;
  }
  
  else if (t <= t1) {
    attenuation = 1.0 - a * (t - t1) * (t - t1);
  }

  else {
    attenuation = 1.0;
  }

  return highest_value_ * (1.0 - attenuation);
}

} // namespace
