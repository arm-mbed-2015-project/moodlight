#pragma once


namespace moodlight {

class Fader {
 public:
  Fader(unsigned int fade_time);
  ~Fader();
  void SetFadeTime(unsigned int fade_time_ms);
  double GetValue(double current_value, unsigned int current_time_ms);
 
 protected:
  double highest_value_;
  double highest_at_ms_;
  double fade_time_ms_;

  double GetFadedValue(unsigned int current_time_ms);
};

} // namespace
