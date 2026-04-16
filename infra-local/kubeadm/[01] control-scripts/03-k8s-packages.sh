#!/usr/bin/env bash
set -euo pipefail

# Keep kubeadm, kubelet, and kubectl on the same Kubernetes minor version.
K8S_MINOR="${K8S_MINOR:-v1.33}"

# Add the Kubernetes apt repository for the chosen minor version.
sudo mkdir -p /etc/apt/keyrings
curl -fsSL "https://pkgs.k8s.io/core:/stable:/${K8S_MINOR}/deb/Release.key" | \
  sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] \
https://pkgs.k8s.io/core:/stable:/${K8S_MINOR}/deb/ /" | \
  sudo tee /etc/apt/sources.list.d/kubernetes.list > /dev/null

sudo apt update
sudo apt install -y kubelet kubeadm kubectl

# Hold the packages to avoid unintended minor-version drift from apt upgrades.
sudo apt-mark hold kubelet kubeadm kubectl

kubeadm version
kubectl version --client

echo "[ok] kube packages installed for ${K8S_MINOR}"
