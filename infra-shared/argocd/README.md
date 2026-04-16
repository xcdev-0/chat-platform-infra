# Argo CD

이 디렉토리에는 GitOps 배포 자산을 둡니다.

의도:

- Jenkins는 이미지를 빌드하고 Helm values의 tag만 갱신
- 실제 배포 반영은 Argo CD가 Git 변경을 감지해 수행

구성:

- `apps/chat-server-dev.yaml`
- `apps/frontend-dev.yaml`
- `root/dev-apps.yaml`

적용 순서:

```bash
kubectl apply -f infra-shared/argocd/root/dev-apps.yaml
```

위 root application 하나만 적용하면 Argo CD가 `infra-shared/argocd/apps/` 아래의 `chat-server-dev`, `frontend-dev` application 을 같이 관리합니다.
