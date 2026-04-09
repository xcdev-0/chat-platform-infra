# Argo CD

이 디렉토리에는 GitOps 배포 자산을 둡니다.

예정 범위:

- root application
- app-of-apps
- `chat-server`, `frontend` application manifest

의도:

- Jenkins는 이미지를 빌드하고 Helm values의 tag만 갱신
- 실제 배포 반영은 Argo CD가 Git 변경을 감지해 수행

현재 시작점:

- `apps/chat-server-dev.yaml`
- Argo CD 설치 후 `kubectl apply -f argocd/apps/chat-server-dev.yaml`
