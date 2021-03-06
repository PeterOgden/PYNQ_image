#!/bin/bash

# Exit if we encounter any errors
set -e
set -x

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd $SCRIPT_DIR

export CT_COMPILE_ROOT=$PWD

# Use cross tools to build the provided configuration
ct-ng arm-linux-gnueabihf,microblazeel-xilinx-elf
ct-ng build

cd microblazeel-xilinx-elf
chmod u+w bin
cd bin

for f in microblazeel-xilinx-elf-*; do
  ln -s $f mb${f#microblazeel-xilinx-elf}
done

cd ..
chmod u-w bin
cd ..
touch build.success
