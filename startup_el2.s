// EL2 entry assembly 

.extern main_el2
.extern _start  // this is EL1 entry symbol
.extern el2_hvc_handler 

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

		// set up exception vector table for EL2
		ldr x0, =vector_el2
		msr VBAR_EL2, x0

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


// vector table EL2
/* vector table needs to be 2KB aligned, hence use .balign to move location counter*/
/* Each entry in vecotr table is of size 128B at most 32 instructions*/
.balign 2048
vector_el2:
// synchronous exceptions
current_el2_sp0_sync:
		mov x10, 0xDEAD
		b current_el2_sp0_sync	
// IRQ
.balign 0x80
current_el2_sp0_irq:
		b current_el2_sp0_irq	

//FIQ
.balign 0x80
current_el2_sp0_fiq:
		b current_el2_sp0_fiq	

// SError
.balign 0x80
current_el2_sp0_serr:
		mov x10, 0xFAFA
		b current_el2_sp0_serr	

// Stack pointer EL2 series
// synchronous exceptions
.balign 0x80
current_el2_sp2_sync:
		mov x10, 0xABAB
		b current_el2_sp2_sync	
// IRQ
.balign 0x80
current_el2_sp2_irq:
		b current_el2_sp2_irq	

//FIQ
.balign 0x80
current_el2_sp2_fiq:
		b current_el2_sp2_fiq	

// SError
.balign 0x80
current_el2_sp2_serr:
		mov x10, 0xDDDD
		b current_el2_sp2_serr	

// Exceptions taken from EL1 to EL2 Aarch64 execution state 
// synchronous exceptions
.balign 0x80
el1_el2_sync:
		// Assume this is HVC call, do HVC processing
		// Get HVC number in x0 and call HVC handler
		mov x0, x10
		// save the link register on el2 stack
		stp x29, x30, [sp, #-16]!
		bl el2_hvc_handler
		ldp x29, x30, [sp], 16
		eret
// IRQ
.balign 0x80
el1_el2_irq:
		b el1_el2_irq  

//FIQ
.balign 0x80
el1_el2_fiq:
		b el1_el2_fiq 

// SError
.balign 0x80
el1_el2_serr:
		mov x10, 0xDDDD
		b el1_el2_serr 




.end
