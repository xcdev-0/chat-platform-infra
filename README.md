# code/infra

이 저장소는 `EJ Labs Market` 인프라 자산을 환경 기준으로 분리해 관리합니다.

핵심 원칙:
- `infra-local`: 홈랩 / kubeadm / 로컬 인증서 / 로컬 dev values
- `infra-aws`: EKS / Terraform / AWS 전용 Helm override
- `infra-shared`: 공통 Helm chart / Argo CD / CI/CD 스크립트

## 디렉토리 구조

```text
code/infra
├── infra-local
│   ├── certs
│   ├── environments
│   └── kubeadm
├── infra-aws
│   ├── helm-values
│   └── terraform
└── infra-shared
    ├── argocd
    ├── cicd
    └── helm
```

## 역할 분리

- `infra-local/`
  - 홈랩용 클러스터 부트스트랩, 로컬 TLS, dev 환경값
- `infra-aws/`
  - EKS Terraform, AWS Load Balancer Controller override, 향후 Route53/ACM/ECR 자산
- `infra-shared/`
  - 환경과 무관하게 재사용할 공통 Helm chart / Argo CD / CI 스크립트

## 로컬 dev 배포 예시

### ingress-nginx

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  -n ingress-nginx \
  --create-namespace \
  --set controller.service.type=NodePort
```

### Argo CD

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

helm upgrade --install argocd argo/argo-cd \
  -f infra-local/environments/dev/platform/argocd-values.yaml \
  -n argocd \
  --create-namespace
```

### data

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

helm upgrade --install mysql bitnami/mysql \
  -f infra-local/environments/dev/data/mysql-values.yaml \
  -n dev --create-namespace

helm upgrade --install redis bitnami/redis \
  -f infra-local/environments/dev/data/redis-values.yaml \
  -n dev --create-namespace

helm upgrade --install kafka bitnami/kafka \
  -f infra-local/environments/dev/data/kafka-values.yaml \
  -n dev --create-namespace
```

### Jenkins

```bash
kubectl apply -f infra-local/environments/dev/platform/jenkins-secrets.local.yaml

helm upgrade --install jenkins ./infra-shared/helm/jenkins-controller \
  -f infra-local/environments/dev/platform/jenkins-values.yaml \
  -n dev --create-namespace
```

### apps

```bash
helm upgrade --install chat-server ./infra-shared/helm/chat-server \
  -f infra-local/environments/dev/apps/chat-server-values.yaml \
  -n dev --create-namespace

helm upgrade --install frontend ./infra-shared/helm/frontend \
  -f infra-local/environments/dev/apps/frontend-values.yaml \
  -n dev --create-namespace
```

## AWS EKS 쪽 기준

- Terraform: `infra-aws/terraform/eks`
- ALB / EKS용 Helm override: `infra-aws/helm-values`
- 공통 chart는 그대로 `infra-shared/helm`

예:

```bash
helm upgrade --install chat-server ./infra-shared/helm/chat-server \
  -f infra-local/environments/dev/apps/chat-server-values.yaml \
  -f infra-aws/helm-values/chat-server-alb-values.example.yaml \
  -n dev
```
