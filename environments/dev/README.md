# dev 환경

이 디렉토리에는 dev 환경 기준 설정을 둡니다.

예정 범위:

- `chat-server-values.yaml`
- `frontend-values.yaml`
- `jenkins-values.yaml`
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
  -f chat-server-values.yaml \
  -n dev --create-namespace

helm upgrade --install frontend ../../helm/frontend \
  -f frontend-values.yaml \
  -n dev --create-namespace

kubectl apply -f jenkins-secrets.example.yaml

helm upgrade --install jenkins-controller ../../helm/jenkins-controller \
  -f jenkins-values.yaml \
  -n dev --create-namespace
```

## 주의

- `chat-server-values.yaml`은 외부 Secret `ejlabs-chat-server-secret`을 참조합니다.
- 민감값은 values 파일에 직접 넣지 않고 Kubernetes Secret으로 따로 관리합니다.
- `jenkins-secrets.example.yaml`은 예시 파일입니다. 실제 private key, Docker Hub token을 넣은 뒤 별도 비공개 파일로 관리해야 합니다.
