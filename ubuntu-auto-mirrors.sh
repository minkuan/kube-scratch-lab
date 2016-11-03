#!/bin/bash

set -x

if [ ! -f /etc/apt/sources.list.bak ]
then
  cp /etc/apt/sources.list /etc/apt/sources.list.bak
  cat /vagrant/ubuntu-auto-mirrors | tee /etc/apt/sources.list
  CODE_NAME=$(lsb_release -a | grep -i codename | awk '{print $2}')
  sed -i "s/CODE_NAME/$CODE_NAME/g" /etc/apt/sources.list
fi
