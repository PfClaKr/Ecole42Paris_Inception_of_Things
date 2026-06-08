#!/bin/bash

# register address to known hosts
sudo echo "192.168.56.110 app1.com" >> /etc/hosts

sudo apt update
sudo apt install systemd-resolved
sudo systemctl enable --now systemd-resolved

sudo resolvectl flush-caches
