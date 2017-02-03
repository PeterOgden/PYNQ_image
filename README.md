# PYNQ image construction

This repo attempts to automate as much as possible the process for building an
image for the PYNQ repository. Sources for dependencies are included as git
submodules. After cloning, run `git submodule init` to initialise the submodule
configuration followed by `git submodule update` to fetch the sources. Please
note, as one of the sources is the Linux kernel, this make take a reasonable
amount of time and disk space. Once the submodules are cloned, run `make` to
create boot files for PYNQ in the boot\_files directory or `make rootfs.img` to
build the complete image

## Setting up the environment

This release has been tested on an Ubuntu 14.04 LTS virtual machine under
VMWare Player setup as described in the doc directory. SDSoC 2016.1 is the
supported release of the Xilinx toolchain although the 2016.1 WebPack editions
of Vivado and SDK could be used instead.

## Stages of Building the Boot Files

### Create an HDF

First task is to create an HDF representing the PYNQ board by creating a simple
Vivado project and exporting the hardware. The only special configuration in
the project are the PL clocks which are configured according to the Overlay
guidelines.

### Create Device Tree

The Xilinx Device Tree Generator add-on to SDK is used to create the sources
for the device tree based on the HDF. A small script is then used to append an
include to some PYNQ specific entries and dtc compiles everything together`

### Create FSBL

A default FSBL project is created based in the HDF file.

### Create u-boot

The Digilent Arty-Z1 board configuration is used as the template to build a
u-boot image. All changes to the enviroment in u-boot are handled through a
uEnv.txt file included in this repo

### Create BOOT.bin

Bootgen collects the base bitstream from the PYNQ repo along the generated FSBL
and u-boot elfs to create BOOT.bin

### Create Kernel

The complete kernel config is included in this repo so all the makefile has to
do is copy it in to the kernel sources and compile.

## Create Root Filesystem

The root filesystem is created by calling `make rootfs.img`. This requires a
new version of qemu to be installed in /opt/qemu and the appropriate binfmt
utils installed for your kernel. Other required packages are multistrap and
crosstools-ng which should be on the PATH. Building the rootfs also recompiles
the kernel as a debian package so that the modules and headers can be easily
installed.

## Updating Components

The version of Vivado/SDK on the PATH when make is invoked should be the
version used to compile the base bitstream. The Kernel version and DTG sources
should be upgraded in lockstep. Using git submodules allows the versions of
each repository used to be recorded unambiguously.

