// EL2 entry assembly 

.extern main_el2
.extern _start  // this is EL1 entry symbol

.text 
.balign 0x800
.global el2_entry
el2_entry:
		// clear registers 
		mov x0, xzr 
		mov x1, xzr 
		mov x2, xzr 
		mov x3, xzr

		// Set up the stack pointer 4KB stack for EL2
		ldr x0, _el2_stack_top
		mov sp, x0

		// jump for el0_main
		bl main_el2 
stay_el2:
		b stay_el2

_el2_stack_top:
		.xword 0x40003000

.align 2 
.global enter_el1
enter_el1:
		// clear system control el1
		msr SCTLR_EL1, xzr

		// set el1 execution state
		mrs x0, HCR_EL2
		orr x0, x0, #(1<<31)
		msr HCR_EL2, x0 // AARCH64 

		// enter EL1 with 64 bit mode
		mov x0, 0b00101
		msr SPSR_EL2, x0
		// _start is el1 entry symbol
		ldr x0, =_start 
		msr ELR_EL2, x0
		eret
		
.end
