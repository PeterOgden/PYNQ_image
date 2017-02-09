#!/bin/bash

set -x

target=$1

fss="proc run dev"

old_hostname=`hostname`

# Make sure that our version of QEMU is on the PATH
export PATH=/opt/qemu/bin:$PATH

# Perform the basic bootstrapping of the image
$dry_run multistrap -f image_config/test.config -d $target --no-auth

$dry_run cp *.deb $target/var/cache/apt/archives

# Copy over what we need to complete the installation
$dry_run cp `which qemu-arm-static` $target/usr/bin
$dry_run cp image_config/*.sh $target
$dry_run cp -r reveal.js $target/root

# Finish the base install
$dry_run chroot $target bash postinst.sh

# Pass through special files so that the chroot works properly
for fs in $fss
do
  $dry_run mount -o bind /$fs $target/$fs
done

# Perform configuration
# Apply patches to the base configuration

for f in $(cd config_diff && find -name "*.diff")
do
  $dry_run sudo patch $target/${f%.diff} < config_diff/$f
done
git describe --long > $target/home/xilinx/REVISION
# Setup Python

export CFLAGS="-mcpu=cortex-a9 -mfpu=neon -funsafe-math-optimizations"
export CPPFLAGS="$CFLAGS"

cp python3.6.optimized.zip $target

$dry_run sudo chroot $target bash install_python.sh
$dry_run sudo chroot $target bash install_pip_packages.sh

# Setup PYNQ
$dry_run cp -r PYNQ $target/home/xilinx/pynq_git
$dry_run chroot $target bash install_pynq.sh

for f in packages/*
do
  if [ -e $f/pre.sh ]; then
    $dry_run $f/pre.sh $target
  fi
  if [ -e $f/qemu.sh ]; then
    $dry_run cp $f/qemu.sh $target
    $dry_run chroot $target bash qemu.sh
    $dry_run rm $target/qemu.sh
  fi
  if [ -e $f/post.sh ]; then
    $dry_run $f/post.sh $target
  fi
done


# Unmount special files
for fs in $fss
do
  $dry_run umount -l $target/$fs
done

# Clean up some of the temporary files
$dry_run rm -f $target/usr/bin/qemu-arm-static
$dry_run rm -f $target/*.sh
$dry_run rm -f $target/pynq_make_diff

$dry_run cp boot_files/* $target/boot


# Kill all processes in the chroot
for f in /proc/*
do
  if [ -e $f/root -a x`readlink -f $f/root` == x`readlink -f $target` ]
  then
    $dry_run kill `basename $f`
  fi
done

# Undo the effect of the hostname script in PYNQ installation
$dry_run hostname $old_hostname
