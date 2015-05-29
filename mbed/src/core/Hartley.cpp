#include "Hartley.h"

#define CAS(i,j) _cas[j>i ? ((j*j+j)>>1)+i : ((i*i+i)>>1)+j]
#define cas(x) sin(x)+cos(x)

namespace moodlight
{
	Hartley::Hartley(const int size)
	{
		uint8_t i, j;
		double pi = atan(1.0)*4;

		_sqrt2 = sqrt(2.0);
		_size = size;
		_cas = (float*) malloc( ((_size * (_size + 1))>>1) * sizeof(float) );
		_buf = (float*) malloc(_size*sizeof(float));

		for(i=0; i<_size; i++)
		{
			for(j=0; j<=i; j++)
			{
				CAS(i,j) = cas( (2*pi*i*j)/_size );
			}
		}
	}

	void Hartley::Transform(float* data, float* result, uint16_t from)
	{
		uint8_t i, j;

		for (i = 0; i < _size; i++)
		{
			_buf[i] = 0;
			for (j = 0; j < _size; j++)
			{
				_buf[i] += data[from+j]*CAS(i, j);
			}
		}

		result[0] = _sqrt2*_buf[0];
		for(i = 1; i<_size/2; i++)
		{
			result[i] = sqrt(2*(_buf[_size - i]*_buf[_size - i] + _buf[i]*_buf[i]));
		}
	}

	Hartley::~Hartley()
	{
		free(_cas);
		free(_buf);
	}

} /* namespace moodsensor */
