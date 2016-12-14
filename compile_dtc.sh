cd pynq_dts
cat system.dts <(echo '/include/ "pynq.dtsi"') | dtc -I dts -O dtb
