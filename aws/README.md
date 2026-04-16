# AWS Deep Dive

이 디렉토리는 `EJ Labs Market`를 AWS 위에서 쿠버네티스 개발자 포트폴리오 수준으로 재구성하기 위한 기준점입니다.

현재 방향:
- 홈랩 `kubeadm` 경험은 유지
- AWS 쪽은 `EKS` 를 메인 축으로 진행
- 목표는 "쿠버네티스 자체를 아는 사람" + "AWS 위에서 실무형으로 운영할 줄 아는 사람"으로 보이게 만드는 것

## 왜 EKS 기준으로 가는가

`EC2 + k3s` 도 빠르게 띄울 수 있지만, 이미 홈랩에서 직접 구축 경험이 있기 때문에 AWS 에서는 차별화 폭이 작습니다.  
반면 `EKS` 는 아래 AWS 실무 축을 함께 보여줄 수 있습니다.

- `VPC`, `subnet`, `route table`, `security group`
- `EKS control plane`
- `managed node group`
- `ECR`
- `IAM`, `OIDC`, `IRSA`
- `AWS Load Balancer Controller`
- `Route53`, `ACM`
- `Argo CD`, `Jenkins` 혹은 `GitHub Actions`

즉 홈랩은 "쿠버네티스를 직접 만든 경험", AWS 는 "관리형 쿠버네티스를 실무적으로 다루는 경험"으로 역할을 분리합니다.

## 포트폴리오 기준 아키텍처

```text
GitHub
  -> CI (Jenkins or GitHub Actions)
  -> ECR image push
  -> infra repo values update
  -> Argo CD sync
  -> EKS rollout

AWS
  ├── VPC
  │   ├── public subnets
  │   └── private subnets
  ├── EKS cluster
  ├── managed node group
  ├── ECR
  ├── IAM OIDC / IRSA
  ├── ALB Controller
  ├── Route53
  └── ACM
```

## 포폴용으로 반드시 보여줄 것

### 1. Terraform 으로 인프라 선언

- VPC
- subnet
- route table
- internet gateway / NAT 여부 판단
- EKS cluster
- node group
- ECR

### 2. EKS 에서 IAM OIDC / IRSA 사용

최소한 아래 중 하나는 IRSA 로 묶는 게 좋습니다.

- `aws-load-balancer-controller`
- `external-dns`
- 애플리케이션 service account

### 3. Ingress 를 AWS 방식으로 연결

- `AWS Load Balancer Controller`
- `Ingress -> ALB`
- 외부 접근을 AWS 네트워크 리소스로 연결

### 4. DNS / TLS

- `Route53`
- `ACM`
- `frontend`, `backend`, `argocd`, `jenkins` 도메인 정리

### 5. GitOps or CI/CD

- 이미지 빌드 후 `ECR` push
- `infra` values tag 갱신
- `Argo CD` 로 자동 반영

## 구현 순서

### Phase 1. 기본 AWS 인프라

- Terraform 으로 `VPC`, `subnet`, `security group`
- `EKS cluster`
- `managed node group`
- `kubectl` 연결 확인

### Phase 2. 클러스터 기본 addon

- `metrics-server`
- `AWS Load Balancer Controller`
- `Argo CD`

### Phase 3. 앱 런타임

- `mysql`, `redis`, `kafka`
- `chat-server`, `frontend`
- `Ingress` 와 ALB 연결

### Phase 4. CI/CD

- `ECR`
- 이미지 build/push
- values update
- `Argo CD` sync

### Phase 5. 운영 완성도

- `Route53`
- `ACM`
- 리소스 requests/limits
- 장애 대응 문서

## 이 디렉토리에서 만들 것

```text
aws
├── README.md
└── terraform
    ├── ec2-k3s
    └── eks
```

`ec2-k3s`:
- 빠른 검증용
- 보조 실험용

`eks`:
- 메인 포트폴리오 대상
- 실제로 깊게 가져갈 스택

## 면접에서 가져갈 메시지

- 홈랩에서는 `kubeadm` 으로 직접 control plane 과 addon 을 다뤘다
- AWS 에서는 `EKS + IAM + ALB + ECR + Argo CD` 로 실무형 배포 흐름을 만들었다
- 즉 "직접 구축형" 과 "관리형 클라우드형" 둘 다 경험했다
