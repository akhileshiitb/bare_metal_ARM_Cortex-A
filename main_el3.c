#include <stdlib.h>
#include <stdint.h>

extern void print_serial(uint8_t * str);

// Entry function in EL2 from El3
extern void enter_el2();

void main_el3(){

		volatile uint32_t main_var_el3 = 20; 
		print_serial("###########");
		print_serial("Starting Cortex A in EL3 exception Level \n");
		print_serial("Connect debugger and set main_var_el3 = 0 to continue ... \n");
		while (main_var_el3 != 0)
		{
		; 
		}

		// Generate synchonous exception and go to EL2
		enter_el2();

}

/* SMC call handeler in EL3 */
void el3_smc_handler(uint64_t smccall_number){

		switch (smccall_number){
				case 1:
						print_serial("[EL3] Entered in EL3 with SMC call number: 1 \n");
						break; 
				case 2: 
						print_serial("[EL3] Entered in EL3 with SMC call number: 2 \n");
						break;
				default:
						print_serial("[EL3] Entered in EL3 but SMC call is not implemented \n");
						break;
		}
}

