#include <stdlib.h>
#include <stdint.h>
uint64_t gVal = 59; 

/* Function implemented in assembly to invert bits of number */
extern uint64_t invert_bits(uint64_t val); 

void print_serial(uint8_t * str)
{
		/* Prints string */
		while (*str != '\0')
		{
				/* 0x90000000 is address of UART TXD of QEMU virt machine model */
				*(uint32_t *)0x9000000 = *str ; 
				str++; 
		}
}

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

		print_serial("Starting Execution on Cortex-A \n");

		while (main_var != 0)
		{
		; 
		}

		main_var = add(5U + gVal,6U); 
		main_var++; 

		main_var = invert_bits(0x0U);

		print_serial("Done with Execution on Cortex-A \n");

		return 0; 
}

