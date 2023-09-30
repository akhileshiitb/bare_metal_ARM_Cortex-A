# bare_metal_ARM_Cortex-A

Bare_metal_ARM_Cortex-A project woks as below: 

QEMU starts Cortex A virt platform in EL3. i

We run startup_el3.S to get to EL3 main_el3(): setting up stacks, MMU tables, Exception vector 

Configure the GIC 

Generate SGI (software generated interrupt) and check its working

Generate Timer PPI interrupt and check its working

Jump to EL2. 

Run startup_el2.S to set up stacks, el2 exception vectors and jump to main_el2()

Do SMC calls and jump tp EL1. 

Run startup.S to get to EL1 main()

Checkout HVC calls. 

jump tp EL0 

run startup_el0.S to get to main_el0()

checkout SVC calls. 

stuck in a loop. 

Apart from above. MMU table is setup in EL3 and virtual ↔ physical address translation and related attribute are checked by EL3 code. 
