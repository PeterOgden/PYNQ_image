export https_proxy=http://proxy
export http_proxy=http://proxy
export PATH=/opt/python3.6/bin:$PATH
export HOME=/root

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
readline
rk
sphinx-rtd-theme
SQLAlchemy
ssh-import-id
urllib3
xlrd
XlsxWriter
xlwt
EOT

# Pillow
# pandas
# deltasigma
# seaborn
# sympy
# numpy
# scipy
# uvloop
# transitions
# pygraphviz
# pyeda
# pycurl
# pygobject
# python-apt
# pyxi
# unattended-upgrades
pip3.6 install numpy requests
for p in $PACKAGES
do 
  pip3.6 install $p
done
