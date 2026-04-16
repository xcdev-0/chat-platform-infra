# Local HTTPS For `*.kube.com`

이 디렉토리는 홈랩용 내부 CA와 `*.kube.com` TLS 인증서를 로컬에서 생성할 때 씁니다.

파일 구성:
- `generate-kube-com-cert.sh`: 내부 Root CA와 `*.kube.com` 서버 인증서 생성
- `apply-kube-com-cert.sh`: 생성된 인증서를 Kubernetes TLS secret으로 반영
- `generated/`: 실제 키/인증서 산출물. git에는 올라가지 않음

기본 secret 이름:
- `dev/kube-com-tls`
- `argocd/argocd-server-tls`

macOS 신뢰 추가:
1. `generate-kube-com-cert.sh` 실행
2. `generated/kube.com-rootCA.pem` 더블클릭
3. 키체인 접근에서 `Always Trust`로 변경
4. 브라우저 완전 종료 후 재실행
