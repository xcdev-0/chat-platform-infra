
## 2. local-path-provisioner

단일 노드 home lab에서 PVC를 쓰기 위한 기본 storage class입니다.

```bash
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.34/deploy/local-path-storage.yaml
kubectl patch storageclass local-path -p '{"metadata":{"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```

확인:

```bash
kubectl -n local-path-storage get pods
kubectl get storageclass
```

성공 기준:

- `local-path-provisioner` pod가 `Running`
- `local-path`가 default storage class
