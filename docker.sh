#!/bin/bash



# sudo kill `ps -fe | grep openconn | grep -v grep | awk '{print $2}'`

# 根据flannel定制docker bip
# cp /vagrant/docker.default /etc/default/docker

# 国内使用阿里云镜像
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

set -x

#apt-get update -qq
apt-get install -y apt-transport-https ca-certificates
# linux-image-extra-$(uname -r) 无须安装，可以干掉
sudo apt-get install -y linux-image-extra-virtual aufs-tools cgroup-lite git git-man liberror-perl libltdl7 libsystemd-journal0

echo '02d926368' | sudo openconnect --background --passwd-on-stdin --reconnect-timeout=30 -uebing a10.blockcn.net:1443
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" | sudo tee /etc/apt/sources.list.d/docker.list
apt-get update -y -qq
apt-cache policy docker-engine
sudo apt-get install -y docker-engine
sudo kill $(ps -fe | grep -v grep | grep openconnect | awk '{print $2}')
# no sudo
# apt-cache policy docker-engine

# apt-get install -y linux-image-extra-$(uname -r) linux-image-extra-virtual

# apt-get install -y docker.io

# service docker status
#service docker stop

# tar zxvf /vagrant/docker-latest.tgz -C /usr/bin --strip-components=1
# cp /vagrant/docker.conf /etc/init/
# groupadd docker
usermod -aG docker vagrant

if [ -f /run/flannel/subnet.env ]; then  
    . /run/flannel/subnet.env
    
    sudo sed -i "s/DOCKER_OPTS=/#DOCKER_OPTS=/g" /etc/default/docker

    echo "DOCKER_OPTS=\"--bip=${FLANNEL_SUBNET} --mtu=${FLANNEL_MTU}\"" | sudo tee -a /etc/default/docker
    # echo "DOCKER=/usr/bin/dockerd" | sudo tee -a /etc/default/docker
fi

service docker stop
# 必须删除docker0网卡，否则DOCKER_OPTS指定的bip无法生效，并且docker服务将起动失败。失败信息/var/log/upstart/docker.log
# sudo ip link delete docker0 
service docker start
# docker version

# apt-get autoremove -y
