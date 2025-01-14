# QEMU ARM EMULATION WITH BUSYBOX AS A ROOTFS

In this guide, we'll walk through the process of setting up QEMU ARM emulation with BusyBox as a root filesystem. This setup allows you to emulate an ARM-based system on your x86_64 Linux machine for development, testing, or experimentation purposes.

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

## Compiling busybox

Get the latest busy box source code from here :- https://busybox.net/

``` bash

$ wget https://busybox.net/downloads/busybox-1.36.1.tar.bz2
$ tar -xf busybox-1.36.1.tar.bz2
$ cd busybox-1.36.1

$ make ARCH=arm CROSS_COMPILE=../gcc-arm-10.3-2021.07-x86_64-arm-none-linux-gnueabihf/bin/arm-none-linux-gnueabihf- defconfig  

$ make ARCH=arm CROSS_COMPILE=../gcc-arm-10.3-2021.07-x86_64-arm-none-linux-gnueabihf/bin/arm-none-linux-gnueabihf- menuconfig

#select the static binary linkage in setting section of menuconfig
#then build the busybox binary  
$ make ARCH=arm CROSS_COMPILE=../gcc-arm-10.3-2021.07-x86_64-arm-none-linux-gnueabihf/bin/arm-none-linux-gnueabihf- -j$(nproc)

#checking for any linkage errors
$ readelf -d busybox | grep NEEDED
#It should come empty

# To install the binaries 
make ARCH=arm CROSS_COMPILE=../gcc-arm-10.3-2021.07-x86_64-arm-none-linux-gnueabihf/bin/arm-none-linux-gnueabihf- -j12 install

```

## Building qemu

Get the qemu source code from here :- https://github.com/qemu/qemu.git

``` bash
git clone https://github.com/qemu/qemu.git
cd qemu

#if kvm is required
./configure --target-list=arm-softmmu,arm-linux-user --enable-kvm

#otherwise  
./configure --target-list=arm-softmmu,arm-linux-user

make -j$(nproc)
```

## Creating rootfs

``` bash
mkdir -p rootfs/{bin,sbin,etc,proc,sys,usr/{bin,sbin}}

#copy all binary to the rootfs generated in the previous step by busybox
cp -av busybox-1.36.1/_install/* rootfs/

cd rootfs

cd dev
# creating tty and mem device for qemu 
mknod -m 660 mem c 1 1
mknod -m 660 tty2 c 4 2
mknod -m 660 tty3 c 4 3
mknod -m 660 tty4 c 4 4

#content of rootfs directory
$ bin  dev  etc  init  linuxrc  proc  sbin  sys  usr

# creating initrd file
find . -print0 | cpio --null -ov --format=newc | gzip -9 > ../rootfs.cpio.gz
```

## Running qemu

``` bash
./build/qemu-system-arm -M virt -m 1024M -kernel linux-6.8.11/arch/arm/boot/zImage -initrd rootfs.cpio.gz -append "root/dev/mem" -nographic
```
Where:

`./build/qemu-system-arm` is the qemu binary  
`-M virt` is the virtual machine type
`linux-6.8.11/arch/arm/boot/zImage` is the kernel image generated by compiling the kernel  
`-initrd rootfs.cpio.gz` is the initrd file  
`-append "root/dev/mem"` is the rootfs  
`-nographic` no graphic window requirement  

check the boot log in `boot.log` file

In cas you see error related to tty or any dev please create those files in rootfs directory and try again by creating again initrd file

## Conclusion

This guide provides a step-by-step walkthrough for setting up QEMU ARM emulation with BusyBox as a root filesystem. Following these instructions, you'll be able to emulate an ARM-based system on your x86_64 Linux machine and perform various development and testing tasks.
