#!/bin/bash
# make copy of old play.s to compare delta
if [ -f play.s ]
then 
		cp play.s play_old.s
fi 

# compile C sources add or remove -g option to add/remove debug symbols from generated assembly
aarch64-none-elf-gcc -g -S -x c main.c -o main.s
aarch64-none-elf-gcc -g -S -x c main_el0.c -o main_el0.s
aarch64-none-elf-gcc -g -S -x c main_el2.c -o main_el2.s
aarch64-none-elf-gcc -g -S -x c main_el3.c -o main_el3.s

# assemble Assemblies
# main.s -> main.obj
aarch64-none-elf-as main.s -o main.obj
aarch64-none-elf-as main_el0.s -o main_el0.obj
aarch64-none-elf-as main_el2.s -o main_el2.obj
aarch64-none-elf-as main_el3.s -o main_el3.obj
aarch64-none-elf-as startup.s -o startup.obj
aarch64-none-elf-as startup_el0.s -o startup_el0.obj
aarch64-none-elf-as startup_el2.s -o startup_el2.obj
aarch64-none-elf-as startup_el3.s -o startup_el3.obj

# open vim with difference 
#vim -d play.s  play_old.s

# linking  --entry is where boot_vectors are set by QEMU
aarch64-none-elf-ld -o image.elf  --entry el3_entry -Tdata 0x40000000 -Ttext 0x40005000 -Map image.map main.obj main_el0.obj main_el2.obj main_el3.obj startup.obj startup_el0.obj startup_el2.obj startup_el3.obj

# object dump tp create binary  
aarch64-none-elf-objcopy  -O binary --gap-fill 0xDE  image.elf image.bin

# use objdump to get symbol resolved assembly back from executable elf
aarch64-none-elf-objdump --disassemble-all  image.elf  > image.dis
