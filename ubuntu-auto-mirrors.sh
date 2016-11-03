#!/bin/bash

set -x

if [ ! -f /etc/apt/sources.list.bak ]
then
  cp /etc/apt/sources.list /etc/apt/sources.list.bak
  cat /vagrant/ubuntu-auto-mirros | tee /etc/apt/sources.list
fi
