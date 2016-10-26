#!/bin/bash

set -x


sudo kill `ps -fe | grep openconn | grep -v grep | awk '{print $2}'`

cp /vagrant/docker.default /etc/default/docker

#if [ ! -f /etc/apt/sources.list.bak ]; then
#  cp /etc/apt/sources.list /etc/apt/sources.list.bak #备份
#  echo "deb http://mirrors.aliyun.com/ubuntu/ trusty main restricted universe multiverse" | sudo tee /etc/apt/sources.list
#  echo "deb http://mirrors.aliyun.com/ubuntu/ trusty-security main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
#  echo "deb http://mirrors.aliyun.com/ubuntu/ trusty-updates main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
#  echo "deb http://mirrors.aliyun.com/ubuntu/ trusty-proposed main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
#  echo "deb http://mirrors.aliyun.com/ubuntu/ trusty-backports main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
#  echo "deb-src http://mirrors.aliyun.com/ubuntu/ trusty main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
#  echo "deb-src http://mirrors.aliyun.com/ubuntu/ trusty-security main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
#  echo "deb-src http://mirrors.aliyun.com/ubuntu/ trusty-updates main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
#  echo "deb-src http://mirrors.aliyun.com/ubuntu/ trusty-proposed main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
#  echo "deb-src http://mirrors.aliyun.com/ubuntu/ trusty-backports main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
#fi

# apt-get update -qq
# apt-get install -y apt-transport-https ca-certificates

# apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

# echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" | sudo tee /etc/apt/sources.list.d/docker.list

# apt-get update -qq

# no sudo
# apt-cache policy docker-engine

# apt-get install -y linux-image-extra-$(uname -r) linux-image-extra-virtual

# apt-get install -y docker.io

# service docker status
# service docker stop

# groupadd docker

# usermod -a -G docker vagrant

#if [ -f /run/flannel/subnet.env ]; then  
#    . /run/flannel/subnet.env
#
#    DOCKER_OPTS="--bip=${FLANNEL_SUBNET} --mtu=${FLANNEL_MTU}"
#fi
# sleep 3
# apt-get install -y bridge-utils
# sudo brctl delbr docker0
service docker stop
sudo ip link delete docker0 
service docker start

