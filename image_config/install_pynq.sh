# Set up some environment variables as /etc/environment
# isn't sourced in chroot

export PATH=/opt/python3.6/bin:$PATH
export BOARD=Pynq-Z1
export HOME=/root

cd /home/xilinx
mkdir scripts
mkdir jupyter_notebooks
mkdir docs
ln -s /opt/python3.6/lib/python3.6/site-packages/pynq pynq

patch pynq_git/scripts/linux/makefile.pynq < /pynq_make_diff
patch pynq_git/scripts/linux/3_pl_server.sh < /pl_server.diff
patch pynq_git/scripts/linux/4_boot_leds.sh < /boot_leds.diff

make -f pynq_git/scripts/linux/makefile.pynq update_pynq

pynq_git/scripts/linux/hostname.sh
chown -R xilinx:xilinx pynq_git

cd /root

export HOME=/root
jupyter notebook --generate-config

cat - >> /root/.jupyter/jupyter_notebook_config.py <<EOT
c.NotebookApp.ip = '0.0.0.0'
c.NotebookApp.nbserver_extensions = {"jupyterlab":True}
c.NotebookApp.notebook_dir = '/home/xilinx/jupyter_notebooks'
c.NotebookApp.password = 'sha1:46c5ef4fa52f:ee46dad5008c6270a52f6272828a51b16336b492'
c.NotebookApp.port = 9090
EOT
