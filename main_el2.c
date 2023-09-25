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

/* HVC call handeler in EL2 */
void el2_hvc_handler(uint64_t hvccall_number){

		switch (hvccall_number){
				case 1:
						print_serial("entered in EL2 with HVC call number: 1 \n");
						break; 
				case 2: 
						print_serial("entered in EL2 with HVC call number: 2 \n");
						break;
				default:
						print_serial("entered in EL2 but HVC call is not implemented \n");
						break;
		}

}


