qemu-system-aarch64 -machine virt -machine virtualization=on -machine secure=on -cpu cortex-a53 -nographic -s -serial telnet:localhost:1111,server  -kernel ~/k3_docker/k3rom-docker/Aarch_64_tools/bare_metal_ARM_Cortex-A/image.elf
