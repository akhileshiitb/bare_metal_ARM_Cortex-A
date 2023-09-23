// EL0 entry assembly 

.extern main_el0

.text 
.align 3
.global el0_entry
el0_entry:
		// clear registers 
		mov x0, xzr 
		mov x1, xzr 
		mov x2, xzr 
		mov x3, xzr

		// Set up the stack pointer 4KB stack for EL0
		mov x0, 0x4000
		mov x1, 0x2000
		mov x0, x0, lsl 16 
		orr x0, x0, x1
		mov sp, x0

		// jump for el0_main
		bl main_el0 
stay_el0:
		b stay_el0

// system call to EL1 (from EL0)
.align 3 
.global system_call
.type system_call, %function
system_call:
		// sys call number is saved in x10 as argument syscall number
		mov x10, x0
		svc 0x0 
		ret

.end
