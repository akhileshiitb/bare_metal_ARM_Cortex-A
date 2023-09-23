#include <stdlib.h>
#include <stdint.h>

extern void print_serial(uint8_t * str);
extern void system_call(uint64_t sys_call_no);

void main_el0()
{
		volatile uint32_t main_var_el0 = 20; 
		print_serial("Cortex-A Processor entered in EL0 exception Level \n");
		while (main_var_el0 != 0)
		{
		; 
		}

		// Generate the exception and goto EL1
		//
		while (1){
		// system call # 1 : 
		system_call(1U);
		print_serial("Back in EL0 \n");

		// system call # 2: 
		system_call(2U);
		print_serial("Back in EL0 \n");

		// system call # 3
		system_call(3U);
		print_serial("Back in EL0 \n");

		}
		
}

