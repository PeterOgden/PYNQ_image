target=$1
fss="proc run"

# Perform the basic bootstrapping of the image
multistrap -f image_config/test.config -d $target --no-auth
cp `which qemu-arm-static` $target/usr/bin
cp image_config/*.sh $target
cp pynq_diffs/* $target
chroot $target bash postinst.sh

# Pass through special files so that the chroot works properly
for fs in $fss
do
  mount -o bind /$fs $target/$fs
done

# Perform configuration
# Apply patches to the base configuration

for f in $(cd config_diff && find -name "*.diff")
do
  sudo patch $target/${f%.diff} < config_diff/$f
done

# Setup Python

sudo chroot $target bash install_python.sh
sudo chroot $target bash install_pip_packages.sh

# Setup PYNQ
git clone https://github.com/Xilinx/PYNQ.git $target/home/xilinx/pynq_git
chroot $target bash install_pynq.sh

# Unmount special files
for fs in $fss
do
  umount -l $target/$fs
done

# Clean up some of the temporary files
rm -f $target/usr/bin/qemu-arm-static
rm -f $target/*.sh
rm -f $target/pynq_make_diff

cp boot_files/* $target/boot
