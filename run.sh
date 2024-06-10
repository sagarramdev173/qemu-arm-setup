#!/bin/bash

# qemu binary patch for arm system
QEMU_PATH="qemu/build/qemu-system-arm"

# memory
MEMORY="256M"

# kernel zImage compiled
KERNEL_PATH="/linux-6.8.11/arch/arm/boot/zImage"

# board which we want to simulate
BOARD="virt"

# path to hello world init program converted to cpio
RAMFS="~/root.cpio.gz"

QEMU_AUDIO_DRV=none $QEMU_PATH -M $BOARD -m $MEMORY -nographic -no-reboot -kernel $KERNEL_PATH -initrd $RAMFS --append "panic=1 console=ttyAMA0 debug=kernel"

# append adds kernel paramters to boot command
# where panic means if it panic exits the qemu booting
