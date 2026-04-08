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
└── helm
    ├── chat-server
    │   └── README.md
    └── frontend
        └── README.md
```

## 먼저 할 일

1. `chat-server` Helm values를 현재 앱 구조에 맞게 정리
   - MySQL 기준 값 제거
   - PostgreSQL, Flyway, Redis, Kafka 환경변수 반영
2. `frontend` Helm values 정리
   - backend URL, websocket URL, ingress host 기준 확정
3. 백엔드 Jenkinsfile 작성
   - build / test / image push / Helm values tag update
4. 프론트 Jenkinsfile 정리
   - 기존 파이프라인 재사용 여부 점검
5. Argo CD app-of-apps 정리
   - `chat-server`, `frontend` 두 앱부터 자동 동기화

## 추천 순서

가장 먼저 손댈 파일은 `helm/chat-server` 쪽입니다.  
현재 애플리케이션은 이미 PostgreSQL + Flyway로 바뀌었는데, 예전 인프라 자산에는 MySQL 기준 값이 남아 있어서 배포 기준이 어긋나 있습니다.
