#!/usr/bin/env bash
set -euo pipefail

# Use the server's LAN IP so other nodes can reach the API server later.
CONTROL_PLANE_IP="${CONTROL_PLANE_IP:-192.168.0.57}"

# Pod CIDR must not overlap the home LAN subnet such as 192.168.0.x.
# If Calico is used, its IP pool must be configured to the same CIDR.
POD_CIDR="${POD_CIDR:-10.244.0.0/16}"

# Bootstrap a single-node control-plane cluster.
sudo kubeadm init \
  --apiserver-advertise-address="${CONTROL_PLANE_IP}" \
  --pod-network-cidr="${POD_CIDR}"

# Copy admin kubeconfig so the current user can run kubectl without sudo.
mkdir -p "$HOME/.kube"
sudo cp -i /etc/kubernetes/admin.conf "$HOME/.kube/config"
sudo chown "$(id -u)":"$(id -g)" "$HOME/.kube/config"

# Single-node home labs usually allow workloads on the control-plane node.
kubectl taint nodes --all node-role.kubernetes.io/control-plane- || true
kubectl get nodes -o wide

echo "[ok] kubeadm init complete"
echo "next: install CNI, storage provisioner, ingress-nginx"
