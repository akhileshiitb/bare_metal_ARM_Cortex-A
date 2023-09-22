#include <stdlib.h>
#include <stdint.h>
uint64_t gVal = 59; 
uint64_t multi(uint64_t data, uint64_t mul_val)
{
		return data*mul_val;
}

uint64_t add(uint32_t a, uint32_t b)
{
		uint64_t val = 80; 
		uint64_t output = 0; 
		uint64_t mul_val = 3; 
		output = a + b + val; 
		mul_val = mul_val >> 1; 
		output = multi(output, mul_val);
		return output; 
}

int main()
{
		volatile uint64_t main_var = 20; 

		while (main_var != 0)
		{
		; 
		}

		main_var = add(5U + gVal,6U); 
		main_var++; 

		return 0; 
}

