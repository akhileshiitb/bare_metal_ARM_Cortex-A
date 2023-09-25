.extern main_el3
.extern el2_entry
.extern el3_smc_handler

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

		// enable SMC calls to EL3 secure monitor
		// clear SCR_EL3.SMD bit to enable SMC calls by EL1, EL2
		mrs x0, SCR_EL3
		mov x1, #(1<<7)
		mvn x1, x1
		and x0, x0, x1 

		// set up exception vector table 
		ldr x0, =vector_el3	
		msr VBAR_EL3, x0
		
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


// vector table EL3
/* vector table needs to be 2KB aligned, hence use .balign to move location counter*/
/* Each entry in vecotr table is of size 128B at most 32 instructions*/
.balign 2048
vector_el3:
// synchronous exceptions
current_el3_sp0_sync:
		mov x10, 0xDEAD
		b current_el3_sp0_sync	
// IRQ
.balign 0x80
current_el3_sp0_irq:
		b current_el3_sp0_irq	

//FIQ
.balign 0x80
current_el3_sp0_fiq:
		b current_el3_sp0_fiq	

// SError
.balign 0x80
current_el3_sp0_serr:
		mov x10, 0xFAFA
		b current_el3_sp0_serr	

// Stack pointer EL2 series
// synchronous exceptions
.balign 0x80
current_el3_sp3_sync:
		mov x10, 0xABAB
		b current_el3_sp3_sync	
// IRQ
.balign 0x80
current_el3_sp3_irq:
		b current_el3_sp3_irq	

//FIQ
.balign 0x80
current_el3_sp3_fiq:
		b current_el3_sp3_fiq	

// SError
.balign 0x80
current_el3_sp3_serr:
		mov x10, 0xDDDD
		b current_el3_sp3_serr	

// Exceptions taken from EL1 to EL2 Aarch64 execution state 
// synchronous exceptions
.balign 0x80
el12_el3_sync:
		// Assume this is SMC call, do SMC processing
		// Get SMC number in x0 and call SMC handler
		mov x0, x10
		// save the link register on el3 stack
		stp x29, x30, [sp, #-16]!
		bl el3_smc_handler
		ldp x29, x30, [sp], 16
		eret
// IRQ
.balign 0x80
el12_el3_irq:
		b el12_el3_irq  

//FIQ
.balign 0x80
el12_el3_fiq:
		b el12_el3_fiq 

// SError
.balign 0x80
el12_el3_serr:
		mov x10, 0xDDDD
		b el12_el3_serr 


.end		

