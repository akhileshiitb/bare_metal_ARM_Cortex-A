// startup script for Aarch64 CPU 

.extern main 
.extern el0_entry
.extern el1_svc_handler

.text
.align 2 
.global _start 

_start:
		// clear registers 
		mov x0, #0 
		mov x1, #0
		mov x2, #0

		// Set up the stack pointer 4KB stack
		mov x0, 0x4000
		mov x1, 0x1000
		mov x0, x0, lsl 16 
		orr x0, x0, x1
		mov sp, x0

		// set up exception vector table
		// vector table for exception level 1
		ldr x0, =vector_el1
		msr VBAR_EL1, x0 

		// clear link register and frame pointer
		mov x30, 0 
		mov x29, 0	

		// jump to main
		bl main 
loop:
	bl loop

.align 2 
.global invert_bits 
.type invert_bits, %function
invert_bits: 		
		mvn x1, xzr  
		eor x0, x0, x1
		ret

.align 2 
.global calc_gcd 
.type calc_gcd, %function 
calc_gcd: 
repeat:
		cmp w0, w1 			
		b.eq done
		subs wzr, w0, w1 
		b.mi smaller
		sub w0, w0, w1
		b repeat 
smaller:
		sub w1, w1, w0 
		b repeat 
done:
		ret

.align 2 
.global my_memcpy
.type my_memcpy, %function 
my_memcpy:
iterate:
		subs w2, w2, 1 
		b.mi exit
		ldrb w3, [x0], 1 
		strb w3, [x1], 1 
		b iterate
exit:
		ret

// vector tables for all exception levels 

// vector table EL1
/* vector table needs to be 2KB aligned, hence use .balign to move location counter*/
/* Each entry in vecotr table is of size 128B at most 32 instructions*/
.balign 2048
vector_el1:
// synchronous exceptions
current_el_sp0_sync:
		mov x10, 0xDEAD
		b current_el_sp0_sync	
// IRQ
.balign 0x80
current_el_sp0_irq:
		b current_el_sp0_irq	

//FIQ
.balign 0x80
current_el_sp0_fiq:
		b current_el_sp0_fiq	

// SError
.balign 0x80
current_el_sp0_serr:
		mov x10, 0xFAFA
		b current_el_sp0_serr	

// Stack pointer EL1 series
// synchronous exceptions
.balign 0x80
current_el_sp1_sync:
		mov x10, 0xABAB
		b current_el_sp1_sync	
// IRQ
.balign 0x80
current_el_sp1_irq:
		b current_el_sp1_irq	

//FIQ
.balign 0x80
current_el_sp1_fiq:
		b current_el_sp1_fiq	

// SError
.balign 0x80
current_el_sp1_serr:
		mov x10, 0xDDDD
		b current_el_sp1_serr	

// Exceptions taken from rl0 to  EL1 Aarch64 execution state 
// synchronous exceptions
.balign 0x80
el0_el1_sync:
		// Assume this is SVC call do SVC processing
		// Get SVC number in x0 and call SVC handler
		mov x0, x10
		// save the link register on el1 stack
		stp x29, x30, [sp, #-16]!
		bl el1_svc_handle
		ldp x29, x30, [sp], 16
		eret
// IRQ
.balign 0x80
el0_el1_irq:
		b el0_el1_irq  

//FIQ
.balign 0x80
el0_el1_fiq:
		b el0_el1_fiq 

// SError
.balign 0x80
el0_el1_serr:
		mov x10, 0xDDDD
		b el0_el1_serr 

// vector table EL2
.balign 2048
vector_el2:
		b vector_el2	
// vector table EL3
.balign 2048
vector_el3:
		b vector_el3	

// code to enter into el0 from el1
.align 2 
.global enter_el0
.type enter_el0, %function
enter_el0:
		mov x0, 0b000000	// EL0 A64 mode
		msr SPSR_EL1, x0
		ldr x0, =el0_entry  // get entry of el0
		msr ELR_EL1, x0    // Update exception link register
		eret 		// call exception return 

.end
