#!/usr/bin/env bash
set -euo pipefail

# Update the base OS first so later package installs start from a clean baseline.
sudo apt update
sudo apt upgrade -y
sudo apt install -y curl ca-certificates gpg apt-transport-https

# kubeadm requires swap to be disabled now and after the next reboot.
sudo swapoff -a
sudo sed -ri '/\sswap\s/s/^/#/' /etc/fstab

# These kernel modules are required by common container networking setups.
cat <<'EOF' | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Kubernetes needs bridge traffic inspection and IPv4 forwarding enabled.
cat <<'EOF' | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system

echo "[ok] baseline complete"
