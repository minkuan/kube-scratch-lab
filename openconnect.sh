#!/bin/bash

set -x
# sudo apt-get update -y -q
# sudo apt-get install -y curl vpnc-scripts build-essential libssl-dev libxml2-dev liblz4-dev


# sudo apt-get update -y -q
# cd /opt/
# mkdir openconnect_7.06
# tar zxf /vagrant/openconnect_7.06.orig.tar.gz -C openconnect_7.06 --strip-components=1
# cd openconnect_7.06
# ./configure --without-gnutls --with-vpnc-script=/usr/share/vpnc-scripts/vpnc-script --disable-nls
# make
# make install
# ldconfig /usr/local/lib

if [ ! -f /etc/apt/sources.list.bak ]
then
  cp /etc/apt/sources.list /etc/apt/sources.list.bak
  sudo echo "deb mirror://mirrors.ubuntu.com/mirrors.txt trusty main restricted universe multiverse" > /etc/apt/sources.list
  sudo echo "deb mirror://mirrors.ubuntu.com/mirrors.txt trusty-backports main restricted universe multiverse" >>/etc/apt/sources.list
  sudo echo "deb mirror://mirrors.ubuntu.com/mirrors.txt trusty-proposed main restricted universe multiverse" >>/etc/apt/sources.list
  sudo echo "deb mirror://mirrors.ubuntu.com/mirrors.txt trusty-security main restricted universe multiverse" >>/etc/apt/sources.list
  sudo echo "deb mirror://mirrors.ubuntu.com/mirrors.txt trusty-updates main restricted universe multiverse" >>/etc/apt/sources.list
  sudo echo "deb-src mirror://mirrors.ubuntu.com/mirrors.txt trusty main restricted universe multiverse" >>/etc/apt/sources.list
  sudo echo "deb-src mirror://mirrors.ubuntu.com/mirrors.txt trusty-backports main restricted universe multiverse" >>/etc/apt/sources.list
  sudo echo "deb-src mirror://mirrors.ubuntu.com/mirrors.txt trusty-proposed main restricted universe multiverse" >>/etc/apt/sources.list
  sudo echo "deb-src mirror://mirrors.ubuntu.com/mirrors.txt trusty-security main restricted universe multiverse" >>/etc/apt/sources.list
  sudo echo "deb-src mirror://mirrors.ubuntu.com/mirrors.txt trusty-updates main restricted universe multiverse" >>/etc/apt/sources.list
fi

# 安装最新版openconnect
sudo add-apt-repository -y ppa:openconnect/daily
sudo apt-get update -y -q
sudo apt-get install openconnect -y -q

# echo '02d926368' | sudo openconnect --background --passwd-on-stdin --reconnect-timeout=30 -uebing a03.blockcn.net:1443
