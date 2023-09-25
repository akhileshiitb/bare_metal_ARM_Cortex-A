#include <stdlib.h>
#include <stdint.h>

extern void print_serial(uint8_t * str);

// Entry function in EL2 from El3
extern void enter_el2();

void main_el3(){

		volatile uint32_t main_var_el3 = 20; 
		print_serial("Cortex-A Processor entered in EL3 exception Level \n");
		while (main_var_el3 != 0)
		{
		; 
		}

		// Generate synchonous exception and go to EL2
		enter_el2();

}

