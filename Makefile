QEMU_EXE ?= $(shell which qemu-arm-static)


all: checkenv boot_files/devicetree.dtb boot_files/uImage boot_files/BOOT.bin
.PHONY: all

pynq.hdf:
	vivado -mode batch -source create_hdf.tcl

pynq_dts/system.dts: pynq.hdf
	hsi -mode batch -source create_device_tree.tcl

pynq_dts/pynq.dtsi: pynq_dts/system.dts pynq.dtsi
	cp pynq.dtsi pynq_dts/

boot_files/devicetree.dtb: pynq_dts/pynq.dtsi pynq_dts/system.dts
	bash compile_dtc.sh > $@

linux-xlnx/.config: pynq_kernel.config
	cp $< $@

linux-xlnx/arch/arm/boot/uImage: linux-xlnx/.config
	cd linux-xlnx && make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- UIMAGE_LOADADDR=2080000 uImage

boot_files/uImage: linux-xlnx/arch/arm/boot/uImage
	cp $< $@

fsbl/executable.elf: pynq.hdf
	hsi -mode batch -source create_fsbl.tcl

boot_gen/fsbl.elf: fsbl/executable.elf
	cp $< $@

u-boot-digilent/u-boot:
	cd u-boot-digilent && make zynq_artyz7_defconfig && patch .config < ../u-boot.config.patch && make CROSS_COMPILE=arm-linux-gnueabihf- ARCH=arm u-boot

boot_gen/u-boot.elf: u-boot-digilent/u-boot
	cp $< $@

boot_gen/bitstream.bit: PYNQ/Pynq-Z1/bitstream/base.bit
	cp $< $@

boot_gen/BOOT.bin: boot_gen/fsbl.elf boot_gen/u-boot.elf boot_gen/bitstream.bit boot_gen/boot.bif
	cd boot_gen && bootgen -image boot.bif -arch zynq -o BOOT.bin -w

boot_files/BOOT.bin: boot_gen/BOOT.bin
	cp $< $@

packages/gcc-mb/build.success:
	bash packages/gcc-mb/build.sh

linux-headers-4.6.0-xilinx_4.6.0-xilinx-3_armhf.deb: linux-xlnx/.config
	cd linux-xlnx && make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- deb-pkg -j4

rootfs.img: boot_files/BOOT.bin boot_files/devicetree.dtb boot_files/uImage packages/gcc-mb/build.success linux-headers-4.6.0-xilinx_4.6.0-xilinx-3_armhf.deb
	sudo bash create_mount_img.sh rootfs.img rootfs_staging
	sudo bash create_rootfs.sh rootfs_staging

.PRECIOUS: rootfs.img

clean:
	rm -rf pynq_dts
	rm -rf simple_pynq
	cd linux-xlnx && make clean
	rm -f devicetree.dtb uImage pynq.hdf
.PHONY: clean

checkenv:
	which dtc
	which hsi
	which vivado
	which arm-linux-gnueabihf-gcc
	which microblaze-xilinx-elf-gcc
	${QEMU_EXE} -version | fgrep 2.8.0
	vivado -version | fgrep 2016.1
	sudo -n true

.PHONY: checkenv
