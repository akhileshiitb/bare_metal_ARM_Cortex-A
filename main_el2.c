#include <stdlib.h>
#include <stdint.h>

extern void print_serial(uint8_t * str);

// Entry function in EL1 from El2
extern void enter_el1();

// SMC call from EL2 ro EL2
extern void system_smc_call(uint64_t smc_call_no);

void main_el2()
{
		volatile uint32_t main_var_el2 = 20; 
		print_serial("###########");
		print_serial("Starting Cortex A in EL2 exception Level \n");

		main_var_el2 = 0;
		while (main_var_el2 != 0)
		{
		; 
		}

		// Checkout secure monitor calls here
		print_serial("[EL2] Making SMC system call to EL3 \n");
		system_smc_call(1U);
		print_serial("[EL2] Back in EL2 after SMC system call \n");

		print_serial("[EL2] Making SMC system call to EL3 \n");
		system_smc_call(2U);
		print_serial("[EL2] Back in EL2 after SMC system call \n");

		print_serial("[EL2] Making SMC system call to EL3 \n");
		system_smc_call(8U);
		print_serial("[EL2] Back in EL2 after SMC system call \n");


		// Generate the exception and goto EL1
		enter_el1();
		
}

/* HVC call handeler in EL2 */
void el2_hvc_handler(uint64_t hvccall_number){

		switch (hvccall_number){
				case 1:
						print_serial("[EL2] Entered in EL2 with HVC call number: 1 \n");
						break; 
				case 2: 
						print_serial("[EL2] Entered in EL2 with HVC call number: 2 \n");
						break;
				default:
						print_serial("[EL2] Entered in EL2 but HVC call is not implemented \n");
						break;
		}

}


