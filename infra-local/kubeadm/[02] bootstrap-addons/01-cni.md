# 05. CNI + Provisioner + Ingress


1. Calico
2. local-path-provisioner
3. ingress-nginx

## 1. Calico

`kubeadm init --pod-network-cidr=10.244.0.0/16` 기준입니다.

```bash
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.31.4/manifests/operator-crds.yaml
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.31.4/manifests/tigera-operator.yaml

cat <<'EOF' | kubectl create -f -
apiVersion: operator.tigera.io/v1
kind: Installation
metadata:
  name: default
spec:
  calicoNetwork:
    ipPools:
      - cidr: 10.244.0.0/16
        natOutgoing: Enabled
        encapsulation: IPIP
        nodeSelector: all()
---
apiVersion: operator.tigera.io/v1
kind: APIServer
metadata:
  name: default
spec: {}
EOF
```

확인:

```bash
kubectl get pods -A
kubectl get pods -n calico-system -w
```

성공 기준:

- `calico-system` pod들이 `Running`
- `kube-system/coredns`가 `Running`

