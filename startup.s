// startup script for Aarch64 CPU 

.extern main 

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

.end
