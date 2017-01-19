/var/lib/dpkg/info/dash.preinst install
export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true
export LC_ALL=C LANGUAGE=C LANG=C
/var/lib/dpkg/info/dash.preinst install
dpkg --configure -a
mount proc -t proc /proc
dpkg --configure -a
rm -rf /var/run/*
dpkg --configure -a
# Horrible hack to work around some resolvconf weirdness
apt-get -y --force-yes purge resolvconf
apt-get -y --force-yes install resolvconf
umount -l /proc

# Create the Xilinx User
adduser --home /home/xilinx xilinx --disabled-password --gecos "Xilinx User,,,,"

echo -e "xilinx\nxilinx" | passwd xilinx
echo -e "xilinx\nxilinx" | smbpasswd -a xilinx
echo -e "xilinx\nxilinx" | passwd root

adduser xilinx adm
adduser xilinx sudo
