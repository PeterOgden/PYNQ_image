export https_proxy=http://proxy
export http_proxy=http://proxy
export PATH=/opt/python3.6/bin:$PATH
export HOME=/root

inter_count=0
max_iterations=3

read -d '' PACKAGES <<EOT
beautifulsoup4
Bottleneck
cffi
chardet
html5lib
jupyter
jupyterlab
lxml
nbsphinx
networkx
numexpr
openpyxl
path.py
pipdeptree
plotly
psutil
pytest-ordering
PyYAML
rk
sphinx-rtd-theme
SQLAlchemy
ssh-import-id
urllib3
xlrd
XlsxWriter
xlwt
scipy
Pillow
pandas
deltasigma
seaborn
sympy
uvloop
transitions
pygraphviz
pyeda
pycurl
EOT

pip3.6 install numpy requests
while [ -n "$PACKAGES" -a "$max_iterations" != "$iter_count" ];
do 
  for p in $PACKAGES
  do 
    pip3.6 install -v $p
    result=$?
    if [ $result != "0" ]; then
      echo "Package $p installed failed" >> pip.failed
      failed_packages="$failed_packages\n $p"
    fi
  iter_count=$(( $inter_count + 1 ))
  PACKAGES="$failed_packages"
  done
done
