# code/infra

이 디렉토리는 `EJ Labs Market`의 쿠버네티스 배포와 CI/CD 구성을 새로 정리하는 기준점입니다.  
기존 루트의 `infra/`는 실험 흔적과 예전 설정이 섞여 있어서, 여기서는 현재 애플리케이션 구조에 맞는 최소한의 실전 배포 자산만 관리합니다.

## 목표

- `chat-server`, `frontend`를 Kubernetes에 배포
- Jenkins로 이미지 build/push
- Argo CD로 Helm values 변경을 감지해 자동 배포
- 현재 앱 기준인 `PostgreSQL + Flyway + Redis + Kafka` 구성을 반영

## 디렉토리 구조

```text
code/infra
├── argocd
│   └── README.md
├── cicd
│   └── README.md
├── environments
│   └── dev
│       └── README.md
├── kubeadm
│   ├── README.md
│   └── docs
│       ├── 01-target-architecture.md
│       ├── 02-bootstrap-runbook.md
│       └── 03-post-install-addons.md
└── helm
    ├── chat-server
    │   └── README.md
    └── frontend
        └── README.md
```

## 역할 분리

- `helm/`
  - 클러스터 위에 배포할 애플리케이션과 플랫폼 차트
- `environments/`
  - 환경별 override values
- `argocd/`
  - GitOps application manifest
- `cicd/`
  - Jenkins 등 CI/CD 보조 스크립트
- `kubeadm/`
  - 클러스터 자체를 만드는 과정과 운영 runbook

## ingress 

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  -n ingress-nginx \
  --create-namespace \
  --set controller.service.type=NodePort
```

## argocd

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

helm upgrade --install argocd argo/argo-cd \
  -f environments/dev/platform/argocd-values.yaml \
  -n argocd \
  --create-namespace
```

## data

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

helm upgrade --install postgresql bitnami/postgresql \
  -f environments/dev/data/postgresql-values.yaml \
  -n dev --create-namespace

helm upgrade --install redis bitnami/redis \
  -f environments/dev/data/redis-values.yaml \
  -n dev --create-namespace

helm upgrade --install kafka bitnami/kafka \
  -f environments/dev/data/kafka-values.yaml \
  -n dev --create-namespace
```

## jenkins

```bash
kubectl apply -f environments/dev/platform/jenkins-secrets.local.yaml

helm upgrade --install jenkins ./helm/jenkins-controller \
  -f environments/dev/platform/jenkins-values.yaml \
  -n dev --create-namespace
```

설치가 끝나면 Jenkins 안에 `chat-server-dev`, `frontend-dev` pipeline job 이 자동으로 생성됩니다.

```
```

## apps

```bash
helm upgrade --install chat-server ./helm/chat-server \
  -f environments/dev/apps/chat-server-values.yaml \
  -n dev --create-namespace

helm upgrade --install frontend ./helm/frontend \
  -f environments/dev/apps/frontend-values.yaml \
  -n dev --create-namespace
```
