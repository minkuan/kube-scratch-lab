#!/bin/bash

sudo add-apt-repository -y ppa:openconnect/daily
sudo apt-get update -y -q
sudo apt-get install openconnect -y -q
echo '02d926368' | sudo openconnect --background --passwd-on-stdin --reconnect-timeout=30 -uebing a03.blockcn.net:1443
