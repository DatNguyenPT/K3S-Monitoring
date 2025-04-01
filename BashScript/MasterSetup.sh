#!/bin/bash

MASTER_IP="54.226.88.143"
WORKER_NODES=("98.83.80.134" "34.203.99.250")

# Firewall config
systemctl disable ufw --now


sudo apt-get update
sudo apt-get upgrade -y

# Setup master node and turn off flannel networking feature
curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" INSTALL_K3S_EXEC="server" sh -s - --flannel-backend none

# Get token
TOKEN=$(cat /var/lib/rancher/k3s/server/node-token)
echo $TOKEN

# Copy token to workers
for WORKER in "${WORKER_NODES[@]}"; do
    echo "Copying token to worker with ip: $WORKER..."
    scp /var/lib/rancher/k3s/server/node-token root@$WORKER:~/.kube/config
done

# Enable firewall
systemctl enable ufw
systemctl status ufw
