.extern main_el3
.extern el2_entry

.text 
.balign 0x800
.global el3_entry
el3_entry:
		// clear registers 
		mov x0, xzr 
		mov x1, xzr 
		mov x2, xzr 
		mov x3, xzr 

		// set up the stack pointer 
		ldr x0, _el3_stack_top
		mov sp, x0
		
		// jump to el3 main
		bl main_el3
stay_el3:
		b stay_el3



_el3_stack_top:
		.xword 0x40004000

.align 2
.global enter_el2
enter_el2:

		// initilize HCR_EL2 and SCTRL_EL2 
		msr HCR_EL2, xzr 
		msr SCTLR_EL2, xzr

		// set EL2 execution state
		mrs x0, SCR_EL3
		orr x0, x0, #(1<<10) // RW El2 execution state is 64 bit 
		orr x0, x0, #(1<<0) // NS bit EL1 non secure world
		msr SCR_EL3, x0

		// enable HVC instruction for EL1 and EL2
		mrs x0, SCR_EL3
		orr x0, x0, #(1<<8)
		msr SCR_EL3, x0

		// set spsr of el3 to el2 exception level
		mov x0, 0b1001
		msr spsr_el3, x0
		// set exception link register of EL3 to EL2 entry symbol
		ldr x0, =el2_entry	
		msr ELR_EL3, x0
		// call ERET instruction 
		eret

.end		

