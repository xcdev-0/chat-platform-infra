# chat-server Helm

여기서는 `chat-server` 배포에 필요한 Helm values와 템플릿 정리 작업을 진행합니다.

우선 반영해야 할 것:

- MySQL datasource
- Flyway 기반 스키마 관리
- Redis endpoint
- Kafka bootstrap server
- JWT secret / app secret
- readiness / liveness probe 경로 점검

첫 작업:

- MySQL 기준 datasource/Flyway 값 유지하기
