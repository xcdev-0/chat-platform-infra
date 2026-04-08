# frontend Helm

여기서는 `frontend-chat-app` 배포에 필요한 Helm values와 템플릿 정리 작업을 진행합니다.

우선 반영해야 할 것:

- backend API URL
- websocket endpoint
- ingress host / TLS
- image tag 갱신 흐름

첫 작업:

- 현재 프론트가 기대하는 API / WS 경로를 기준으로 values 정리
