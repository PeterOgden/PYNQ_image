cd /root
export http_proxy=http://proxy
export https_proxy=http://proxy
wget https://www.python.org/ftp/python/3.6.0/Python-3.6.0.tar.xz
tar -xf Python-3.6.0.tar.xz
cd Python-3.6.0
# There's a bug in the released version of python that we need to patch
# otherwise Jupyter/python won't start properly during boot
patch Modules/_randommodule.c <<EOT
--- Modules/_randommodule.c	2016-12-23 02:21:21.000000000 +0000
+++ Modules/_randommodule.c.new	2017-01-03 13:27:06.006651637 +0000
@@ -245,7 +245,7 @@
         return NULL;
 
      if (arg == NULL || arg == Py_None) {
-        if (random_seed_urandom(self) >= 0) {
+        if (random_seed_urandom(self) < 0) {
             PyErr_Clear();
 
             /* Reading system entropy failed, fall back on the worst entropy:
EOT

./configure --prefix=/opt/python3.6
make -j 4 altinstall
