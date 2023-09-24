#include <stdlib.h>
#include <stdint.h>

extern void print_serial(uint8_t * str);

// Entry function in EL1 from El2
extern void enter_el1();

void main_el2()
{
		volatile uint32_t main_var_el2 = 20; 
		print_serial("Cortex-A Processor entered in EL2 exception Level \n");
		while (main_var_el2 != 0)
		{
		; 
		}

		// Checkout secure monitor calls here
		// TODO

		// Generate the exception and goto EL1
		enter_el1();
		
}

