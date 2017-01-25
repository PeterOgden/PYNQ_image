# PYNQ image construction

This repo attempts to automate as much as possible the process for building a
PYNQ repository. Sources for dependencies are included as git submodules. After
cloning, run `git submodule init` to initialise the submodule configuration
followed by `git submodule update` to fetch the sources. Please note, as one of
the sources is the Linux kernel, this make take a reasonable amount of time and
disk space. Once the submodules are cloned, run `make` to create boot files for
PYNQ in the boot\_files directory.

## Stages of Building

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

## Updating Components

The version of Vivado/SDK on the PATH when make is invoked should be the
version used to compile the base bitstream. The Kernel version and DTG sources
should be upgraded in lockstep. Using git submodules allows the versions of
each repository used to be recorded unambiguously.

# Create Root Filesystem

The root filesystem is created by calling `make rootfs.img`. This requires a
new version of qemu to be installed in /opt/qemu and the appropriate binfmt
utils installed for your kernel. Other required packages are multi-strap and
crosstools-ng which should be on the PATH.
