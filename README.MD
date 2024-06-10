# QEMU ARM EMULATION WITH HELLO WORLD INIT PROGRAM

In this guide, we'll walk through the process of setting up QEMU ARM emulation with hello world init program. This setup allows you to emulate an ARM-based system on your x86_64 Linux machine for development, testing, or experimentation purposes.

system configuration

``` bash
#Oracle linux 8
5.15.0-204.147.6.2.el8uek.x86_64
```

## Getting tool chain

Get the cross compilation tool chain form :- https://developer.arm.com/downloads/-/gnu-a

### x86_64 Linux hosted cross compilers

#### AArch32 target with hard float (arm-none-linux-gnueabihf)

``` bash
wget https://developer.arm.com/-/media/Files/downloads/gnu-a/10.3-2021.07/binrel/gcc-arm-10.3-2021.07-x86_64-arm-none-linux-gnueabihf.tar.xz
```

## Compiling kernel

Get the latest kernel from here :- https://kernel.org/

we have taken this stable version

``` bash
wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.8.11.tar.xz  [stable:6.8.11]
```

Compiling kernel :-

Set the default configuration for arm achitecture as :

``` bash
make ARCH=arm CROSS_COMPILE=../gcc-arm-10.3-2021.07-x86_64-arm-none-linux-gnueabihf/bin/arm-none-linux-gnueabihf- defconfig
```

CROSS_COMPILE path will be where you extracted the tool chain

Building kernel

``` bash
make ARCH=arm CROSS_COMPILE=../gcc-arm-10.3-2021.07-x86_64-arm-none-linux-gnueabihf/bin/arm-none-linux-gnueabihf-  -j$(nproc)
```

## Building qemu

Get the qemu source code from here :- https://github.com/qemu/qemu.git

``` bash
git clone https://github.com/qemu/qemu.git
cd qemu

#if kvm is required
./configure --target-list=arm-softmmu,arm-linux-user --enable-kvm

#otherwise  k
./configure --target-list=arm-softmmu,arm-linux-user

make -j$(nproc)
```

## Creating rootfs

``` bash
# create simple hello world program 

#include<stdio.h>
#include <unistd.h>

int main(int argc,char argv[]){

    printf("hello world\n");
    sleep(999999);
    return 0;
}
# we need to sleep in this so that our program don't end and return 

# cross compiling hello world program
arm-linux-gnueabihf-gcc -static -o hello hello.c
# here  arm-linux-gnueabihf-gcc is the cross compiler which we got from tool chain

# creating rootfs
find . | cpio -o -H newc | gzip > root.cpio.gz

```

## Running qemu

``` bash

## attached in the repo
./run.sh


#You should see 
# <<cropped>>
[    2.025391] input: gpio-keys as /devices/platform/gpio-keys/input/input0
[    2.777924] clk: Disabling unused clocks
[    2.931126] Freeing unused kernel image (initmem) memory: 2048K
[    2.955199] Run /init as init process
[    2.955510]   with arguments:
[    2.955760]     /init
[    2.955960]   with environment:
[    2.956203]     HOME=/
[    2.956389]     TERM=linux
hello world

```

## Conclusion

This guide provides a step-by-step walkthrough for setting up QEMU ARM emulation with simple hello world program. Following these instructions, you'll be able to emulate an ARM-based system on your x86_64 Linux machine and perform various development and testing tasks.

## Reference
kernel documentation :- 
https://www.kernel.org/doc/Documentation/filesystems/ramfs-rootfs-initramfs.rst

Youtube video :- https://www.youtube.com/watch?v=Sk9TatW9ino
