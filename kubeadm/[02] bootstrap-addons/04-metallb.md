# 04. MetalLB

bare metal kubeadm 클러스터에서 `LoadBalancer` 타입 서비스를 쓰기 위한 단계입니다.

역할:

- `ingress-nginx-controller`에 LAN IP 할당
- `argocd.kube.com`, `jenkins.kube.com` 같은 도메인을 포트 없이 깔끔하게 사용


까지 끝난 상태

## 1. 설치

```bash
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.15.2/config/manifests/metallb-native.yaml
```

확인:

```bash
kubectl -n metallb-system get pods
```

성공 기준:

- `controller` 가 `Running`
- `speaker` 가 `Running`

## 2. IP 풀 생성

주의:

- 아래 대역은 예시입니다
- 반드시 집 네트워크에서 비어 있는 IP 범위를 사용해야 합니다
- DHCP 자동 할당 범위와 겹치면 안 됩니다

예시:

- LAN: `192.168.0.0/24`
- Node: `192.168.0.57`
- MetalLB pool: `192.168.0.240-192.168.0.250`

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: default-pool
  namespace: metallb-system
spec:
  addresses:
    - 192.168.0.240-192.168.0.250
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: default
  namespace: metallb-system
spec: {}
EOF
```

확인:

```bash
kubectl get ipaddresspools -n metallb-system
kubectl get l2advertisements -n metallb-system
```

## 3. ingress-nginx를 LoadBalancer로 변경

기존에 `NodePort`로 설치한 ingress-nginx를 `LoadBalancer`로 바꿉니다.

```bash
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  -n ingress-nginx \
  --create-namespace \
  --set controller.service.type=LoadBalancer
```

또는 서비스만 빠르게 patch:

```bash
kubectl -n ingress-nginx patch svc ingress-nginx-controller \
  -p '{"spec":{"type":"LoadBalancer"}}'
```

## 4. 외부 IP 확인

```bash
kubectl -n ingress-nginx get svc ingress-nginx-controller -w
```

성공 기준:

- `EXTERNAL-IP`에 `192.168.0.240` 같은 LAN IP가 할당됨

