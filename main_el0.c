#include <stdlib.h>
#include <stdint.h>

extern void print_serial(uint8_t * str);
extern void system_call(uint64_t sys_call_no);

void main_el0()
{
		volatile uint32_t main_var_el0 = 20; 
		print_serial("###########");
		print_serial("Starting Cortex A in EL0 exception Level \n");

		// Generate the exception and goto EL1
		print_serial("[EL0] Making SVC system call to EL1 \n");
		// system call # 1 : 
		system_call(1U);
		print_serial("[EL0] Back in EL0 after SVC system call \n");

		// system call # 2: 
		print_serial("[EL0] Making SVC system call to EL1 \n");
		system_call(2U);
		print_serial("[EL0] Back in EL0 after SVC system call \n");

		// system call # 3
		print_serial("[EL0] Making SVC system call to EL1 \n");
		system_call(3U);
		print_serial("[EL0] Back in EL0 after SVC system call \n");

		print_serial("DONE EXECUTION: stucking in loop at EL0");
		while (main_var_el0 != 0)
		{
		; 
		}

		
}

