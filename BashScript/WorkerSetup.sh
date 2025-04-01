#!/bin/bash

MASTER_IP="54.226.88.143"

# Firewall config
systemctl disable ufw --now

sudo apt-get update
sudo apt-get upgrade -y

# Setup worker node
TOKEN=$(cat ~/.kube/config | grep 'token:' | awk '{print $2}')

curl -sfL https://get.k3s.io | K3S_URL=https://$MASTER_IP:6443 K3S_TOKEN=$TOKEN sh -

# Enable firewall
systemctl enable ufw
systemctl status ufw
