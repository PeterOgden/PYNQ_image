
all: devicetree.dtb uImage
.PHONY: all

pynq.hdf:
	vivado -mode batch -source create_hdf.tcl

pynq_dts/system.dts: pynq.hdf
	hsi -mode batch -source create_device_tree.tcl

pynq_dts/pynq.dtsi: pynq_dts/system.dts pynq.dtsi
	cp pynq.dtsi pynq_dts/

devicetree.dtb: pynq_dts/pynq.dtsi pynq_dts/system.dts
	bash compile_dtc.sh > devicetree.dtb

linux-xlnx/.config: pynq_kernel.config
	cp $< $@

linux-xlnx/arch/arm/boot/uImage: linux-xlnx/.config
	cd linux-xlnx && make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- UIMAGE_LOADADDR=2080000 uImage

uImage: linux-xlnx/arch/arm/boot/uImage
	cp $< $@

clean:
	rm -rf pynq_dts
	rm -rf simple_pynq
	cd linux-xlnx && make clean
	rm -f devicetree.dtb uImage pynq.hdf
.PHONY: clean
