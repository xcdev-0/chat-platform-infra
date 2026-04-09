# dev 환경

이 디렉토리에는 dev 환경 기준 설정을 둡니다.

구조:

- `apps/`
  - `chat-server-values.yaml`
  - `frontend-values.yaml`
- `platform/`
  - `argocd-values.yaml`
  - `jenkins-values.yaml`
  - `jenkins-secrets.example.yaml`
- `data/`
  - `postgresql-values.yaml`
  - `redis-values.yaml`
  - `kafka-values.yaml`
- ingress host
- image tag 정책
- database / redis / kafka endpoint
- secret 참조 방식

원칙:

- 애플리케이션 공통 템플릿은 `helm/`
- 환경별 차이는 `environments/dev/`에서 override

## 사용 예시

```bash
helm upgrade --install chat-server ../../helm/chat-server \
  -f apps/chat-server-values.yaml \
  -n dev --create-namespace

helm upgrade --install frontend ../../helm/frontend \
  -f apps/frontend-values.yaml \
  -n dev --create-namespace

kubectl apply -f platform/jenkins-secrets.example.yaml

helm upgrade --install jenkins-controller ../../helm/jenkins-controller \
  -f platform/jenkins-values.yaml \
  -n dev --create-namespace

helm upgrade --install argocd argo/argo-cd \
  -f platform/argocd-values.yaml \
  -n argocd --create-namespace

helm upgrade --install postgresql bitnami/postgresql \
  -f data/postgresql-values.yaml \
  -n dev --create-namespace

helm upgrade --install redis bitnami/redis \
  -f data/redis-values.yaml \
  -n dev --create-namespace

helm upgrade --install kafka bitnami/kafka \
  -f data/kafka-values.yaml \
  -n dev --create-namespace
```

## 주의

- `apps/chat-server-values.yaml`은 dev 기준으로 chart가 자체 Secret을 생성합니다.
- `data/kafka-values.yaml`은 Docker Hub에서 현재 내려가지 않는 기본 `bitnami/kafka` 대신 `bitnamilegacy/kafka`를 사용합니다.
- 민감값은 values 파일에 직접 넣지 않고 Kubernetes Secret으로 따로 관리합니다.
- `platform/jenkins-secrets.example.yaml`은 예시 파일입니다. 실제 private key, Docker Hub token을 넣은 뒤 별도 비공개 파일로 관리해야 합니다.
