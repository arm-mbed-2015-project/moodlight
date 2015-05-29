#ifndef CORE_HARTLEY_H_
#define CORE_HARTLEY_H_

#include "mbed.h"

namespace moodlight
{

class Hartley
{

public:
	Hartley(const int size);
    void Transform(float* data, float* result, uint16_t from = 0);
    ~Hartley();

private:
    int _size;
    float* _cas;
    float* _buf;
    float _sqrt2;

};

} /* namespace moodsensor */

#endif /* CORE_HARTLEY_H_ */
