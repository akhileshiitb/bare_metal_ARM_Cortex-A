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

.end
