#include <stdlib.h>
#include <stdint.h>

extern void print_serial(uint8_t * str);

// Entry function in EL2 from El3
extern void enter_el2();

extern uint64_t _ttb_1_base;

// translation table 2 with 512 , 2 MB blocks
uint64_t _ttb_2_base[512] __attribute__(( aligned (0x1000) ));

void init_l2_table(){
		// initiliza all 2MB blocks in L2 table 
		// Add address of table 2 ino 3rd entry of  table 1 
		int i; 
		uint64_t *ttb_1 = (uint64_t *)&_ttb_1_base;
		uint64_t ttb_2_base_addr = (uint64_t) &_ttb_2_base[0];
		*(ttb_1 + 3) = (ttb_2_base_addr & 0xFFFFF000) | 0x3;  // point to L2 table is is table entry 
		
		// iterate and fill all 2 MB blocks 
		for (i=0; i< 512; i++)
		{
				_ttb_2_base[i] = (0x741) | (0x40000000 + i*2*1024*1024);
		}
}

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

