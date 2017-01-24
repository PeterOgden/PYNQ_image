target=$1
fss="proc run dev"

old_hostname=`hostname`

# Make sure that our version of QEMU is on the PATH
export PATH=/opt/qemu/bin:$PATH

# Perform the basic bootstrapping of the image
multistrap -f image_config/test.config -d $target --no-auth

cp *.deb $target/var/cache/apt/archives

# Copy over what we need to complete the installation
cp `which qemu-arm-static` $target/usr/bin
cp image_config/*.sh $target
cp -r reveal.js $target/root

# Finish the base install
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
cp -r PYNQ $target/home/xilinx/pynq_git
chroot $target bash install_pynq.sh

chroot $target bash install_sigrok.sh
chroot $target bash install_opencv.sh

bash packages/xkcd/install.sh $target

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

cp -r packages/gcc-mb/microblazeel-xilinx-elf $target/opt
chown root:root -R $target/opt/microblazeel-xilinx-elf


# Kill all processes in the chroot
for f in /proc/fd/*
do
  if [ -e $f/root -a x`readlink -f $f/root` == x`readlink -f $target` ]
  then
    kill `basename $fd`
  fi
done

# Undo the effect of the hostname script in PYNQ installation
hostname $old_hostname
