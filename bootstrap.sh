#!/bin/bash
sudo apt-get update
sudo apt-get -y install nginx

export HOSTNAME=$(hostname | tr -d '\n')
export PRIVATE_IP=$(curl -sf -H 'Metadata-Flavor:Google' http://metadata/computeMetadata/v1/instance/network-interfaces/0/ip | tr -d '\n')
sudo echo "Welcome to $HOSTNAME - $PRIVATE_IP" > /usr/share/nginx/html/index.html
sudo service nginx restart
