
local에서 쿠브 접속하기

```sh
mkdir -p ~/.kube
scp dmswjd@192.168.0.57:~/.kube/config ~/.kube/config-mykube

cp ~/.kube/config ~/.kube/config.backup
KUBECONFIG=$HOME/.kube/config-mykube:$HOME/.kube/config kubectl config view --flatten > /tmp/kubeconfig
mv /tmp/kubeconfig ~/.kube/config

kubectl config use-context 
kubectl get nodes
```