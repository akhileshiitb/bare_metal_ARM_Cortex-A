.extern main_el3
.extern el2_entry
.extern el3_smc_handler
.extern init_l2_table

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

		// Set up MMU tables first 1GB to 0x8000_0000
		mrs x0, ID_AA64MMFR0_EL1

		// Set up MMU 4KB granule and 1GB block 2 define two blocks of 1GB  
		// Inner sharable 
		mov x0, 0x3520
		// 40 bit physical address
		orr x0, x0 , #(2<<16)
		MSR TCR_EL3, x0

		// set up attribute encodings.ATTR0: Device ATTR1: Normal Cachable
		ldr x1, =0xFF440400
		msr MAIR_EL3, x1

		// set up transation table base
		// _ttb_0_base must be 4KB alinged as granule size is 4KB
		LDR x0, =_ttb_1_base
		msr TTBR0_EL3, x0

		// level1 table 
		ldr x0, =_ttb_1_base
		ldr x1, [x0]

		bl init_l2_table	
		
		// enable MMU 
		mrs x0, SCTLR_EL3
		orr x0, x0, 0x1 
		msr SCTLR_EL3, x0 
		DSB SY 
		ISB

		// jump to el3 main
		bl main_el3
stay_el3:
		b stay_el3



_el3_stack_top:
		.xword 0x40004000

.align 12 
.global _ttb_1_base
_ttb_1_base:
		.xword  0x00000741  // 1st 1GB VA to PA
		.xword  0x40000741  // 2nd 1 GB  VA to PA = 0x4000_0000
		.xword  0x40000741  // 3nd 1 GB  VA to PA = 0x8000_0000
		.xword  0x40000741  // 4nd 1 GB  VA to PA = 0xD000_0000 point to L2 table
		

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

.align 2
.global init_gic_cpu_interface
.type init_gic_cpu_interface, %function
init_gic_cpu_interface:
		// Enable Access to CPU interface system registers for all ELs
		mrs x0, ICC_SRE_EL3
		orr x0, x0, #(0x1)
		msr ICC_SRE_EL3, x0
		mrs x0, ICC_SRE_EL2
		orr x0, x0, #(0x1)
		msr ICC_SRE_EL2, x0
		mrs x0, ICC_SRE_EL1
		orr x0, x0, #(0x1)
		msr ICC_SRE_EL1, x0

		// set priority mask and binary point registers 
		// Priority mask: Lowest priority = 0xFF
		mov x0, #(0xFF) // lowest priority possible
		msr ICC_PMR_EL1, x0
		// Binary point for preemption point = 4
		mov x0, 0x4  // 4 bits split
		msr ICC_BPR1_EL1, x0  // group 1 preemption setting
		msr ICC_BPR0_EL1, x0  // group 0 preemption setting

		// configution EOI(end of interrupt)
		mrs x0, ICC_CTLR_EL3
		mov x2, #(1<<1)
		mvn x1, x2 
		and x0, x0, x1
		msr ICC_CTLR_EL3, x0
		mrs x0, ICC_CTLR_EL1 // for current sec state
		mov x2, #(7<<2)
		mvn x1, x2 
		and x0, x0, x1
		msr ICC_CTLR_EL1, x0

		// Enable signalling each interrupt group
		// Enable Group 0 interrupts
		mov x0, #(0x1)
		msr ICC_IGRPEN0_EL1, x0
		mov x0, #(0x3)
		msr ICC_IGRPEN1_El3, x0 // enable both S/NS GRP1 interrupts

		// unmask CPU interrupts all DAIF
		mov x0, #0
		msr DAIF, x0

		// route IRQ and FIQ to EL3
		// route both IRQ and FIQ to EL3
		mov x0, 0x6
		mrs x1, SCR_EL3
		orr x1, x1, x0
		msr SCR_EL3, x1

		ret

.align 2 
.global generate_sgi_interrupt
.type generate_sgi_interrupt, %function 
generate_sgi_interrupt: 
		// store corruptable registers
		stp x29, x30, [sp, #-16]!
		// FYI: Read the affinity value of current processor
		mrs x10, MPIDR_EL1
		// trigger the SGI 
		mov x6, #0
		orr x6, x6, x0 , lsl 16
		orr x6, x6, x1, lsl 32
		orr x6, x6, x2, lsl 48
		orr x6, x6, x3, lsl 0
		orr x6, x6, x4, lsl 24  // Interrupt ID
		msr ICC_SGI0R_EL1, x6
		ldp x29, x30, [sp, #16]
		ret

.align 2
.global enable_timer_interrupt
.type enable_timer_interrupt, %function
enable_timer_interrupt:
		// Enable and Physical timer EL0 for interrupt
		mov x1, 0x0 // ENABLE = 1, IMASK = 0, ISTATUS = 0
		msr CNTP_CTL_EL0, x1
		mov x1, 0x1
		msr CNTP_CTL_EL0, x1
		// Write to TVAL to trigger timer
		msr CNTP_TVAL_EL0, x0
		ret

.align 2 
.global ack_timer
.type ack_timer, %function 
ack_timer:
		mov x0, #2
		msr CNTP_CTL_EL0, x0
		ret


		
		

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
		stp x29, x30, [sp, #-16]!
		stp x0, x1, [sp, #-16]!
		// Acknowledge the group 0 interrupt
		mrs x0, ICC_IAR0_EL1
		mov x11, x0 // save interrupt number
		// call the interrupt handler
		bl el3_fiq_handler
		// Mark the EOI (End of Interrupt)
		msr ICC_EOIR0_EL1, x11
		ldp x29, x30, [sp, #16]
		ldp x0, x1, [sp, #16]
	    eret	

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

