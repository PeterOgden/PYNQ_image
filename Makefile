
all: devicetree.dtb
.PHONY: all

pynq.hdf:
	vivado -mode batch -source create_hdf.tcl

pynq_dts/system.dts: pynq.hdf
	hsi -mode batch -source create_device_tree.tcl

pynq_dts/pynq.dtsi: pynq_dts/system.dts pynq.dtsi
	cp pynq.dtsi pynq_dts/

devicetree.dtb: pynq_dts/pynq.dtsi pynq_dts/system.dts
	bash compile_dtc.sh > devicetree.dtb

