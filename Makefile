
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
	cd u-boot-digilent && make zynq_artyz7_defconfig && make CROSS_COMPILE=arm-linux-gnueabihf-

boot_gen/u-boot.elf: u-boot-digilent/u-boot
	cp $< $@

boot_gen/bitstream.bit: PYNQ/Pynq-Z1/bitstream/base.bit
	cp $< $@

boot_gen/BOOT.bin: boot_gen/fsbl.elf boot_gen/u-boot.elf boot_gen/bitstream.bit
	cd boot_gen && bootgen -image boot.bif -arch zynq -o BOOT.bin

boot_files/BOOT.bin: boot_gen/BOOT.bin
	cp $< $@

rootfs.img: boot_files/BOOT.bin boot_files/devicetree.dtb boot_files/uImage
	bash create_mount_img.sh rootfs.img rootfs_staging
	bash create_rootfs.sh rootfs_staging

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

.PHONY: checkenv
