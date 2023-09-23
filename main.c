#include <stdlib.h>
#include <stdint.h>
uint64_t gVal = 59; 

/* Function implemented in assembly to invert bits of number */
extern uint64_t invert_bits(uint64_t val); 

/* Assembly function to calculate GCD of two words */
/* This helps to understand data processing and flow control of ARM ISA, Excercise from offical ARM documentaion */
extern uint32_t calc_gcd(uint32_t num1, uint32_t num2);

/* Assembly function for memory copy my_memcpy 
 * Taken from ARM official excercises. 
 * Helps: Understand accessing memory. 
 * */
extern void my_memcpy(uint8_t * src, uint8_t * dest, uint32_t size_bytes);

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
		uint8_t src_arr[4] = {1, 2, 3, 4}; 
		uint8_t dest_arr[4] = {0, 0, 0, 0}; 

		print_serial("Starting Execution on Cortex-A \n");

		while (main_var != 0)
		{
		; 
		}

		main_var = add(5U + gVal,6U); 
		main_var++; 

		main_var = invert_bits(0x0U);
		main_var = (uint64_t)calc_gcd(50U, 75U);

		/* Test my_memcpy function */
		my_memcpy(src_arr, dest_arr, 2U);

		print_serial("Done with Execution on Cortex-A \n");

		// create data abort system exception 
		// This isexpected to generate sync falut current spx
		// Observe if program flow goes to Vector table of ELx
		*(uint32_t *) 0xFFFFFFFF = 0xDD; 

		return 0; 
}

