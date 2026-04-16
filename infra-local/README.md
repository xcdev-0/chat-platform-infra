# infra-local

홈랩 / 로컬 쿠버네티스 운영 자산을 둡니다.

구성:
- `kubeadm/`: control plane, worker, addon 부트스트랩 문서/스크립트
- `certs/`: `*.kube.com` 로컬 TLS 인증서 생성 및 반영 스크립트
- `environments/`: 로컬 dev 환경용 Helm override values
