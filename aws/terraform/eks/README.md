# EKS Stack

이 디렉토리는 `EJ Labs Market`의 AWS 메인 포트폴리오 스택입니다.

목표:
- `Terraform` 으로 `EKS` 구성
- `ECR` 로 이미지 배포
- `AWS Load Balancer Controller` 로 ingress 연결
- `Route53 + ACM` 으로 도메인/TLS 정리
- `Argo CD` 로 GitOps 배포

현재 구현 범위:
1. `VPC`
2. `public/private subnet`
3. `single NAT gateway`
4. `EKS cluster`
5. `managed node group`
6. `kubectl` 연결용 output

## 파일 구조

```text
eks
├── .gitignore
├── main.tf
├── outputs.tf
├── providers.tf
├── terraform.tfvars.example
├── variables.tf
├── versions.tf
└── modules
    ├── cluster
    ├── network
    └── node-group
```

## 설계 기준

### network
- VPC 1개
- AZ 2개 기본
- public subnet 2개
- private subnet 2개
- NAT gateway 1개

초기 비용을 줄이기 위해 private subnet 에 대한 NAT 는 단일 NAT 로 시작합니다.  
운영형 고가용성 구조라면 AZ 별 NAT gateway 로 확장하면 됩니다.

### cluster
- EKS control plane
- public/private API endpoint 동시 허용
- public endpoint 는 `cluster_endpoint_public_access_cidrs` 로 제한
- control plane log 를 CloudWatch 에 보냄

### node-group
- managed node group
- 기본 instance type 은 `t4g.medium`
- 기본 AMI 는 `AL2023_ARM_64_STANDARD`

`arm64` 를 기본으로 둔 이유는 비용 대비 효율이 좋고, 지금 프로젝트도 arm64 환경과 크게 충돌하지 않기 때문입니다.

## 버전 기준

기본 `cluster_version` 은 `1.33` 으로 잡았습니다.  
이 값은 2026-04-15 기준 Amazon EKS 표준 지원 버전 목록 안에 있는 버전입니다.  
공식 문서: https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html

## 사용 순서

```bash
cd code/infra/aws/terraform/eks

cp terraform.tfvars.example terraform.tfvars
```

`terraform.tfvars` 에서 최소한 아래 값은 조정하는 게 좋습니다.

- `aws_region`
- `cluster_endpoint_public_access_cidrs`
- 필요하면 node group size / instance type

그 다음:

```bash
terraform init
terraform validate
terraform plan
terraform apply
```

## kubeconfig 연결

apply 후 output:

```bash
aws eks update-kubeconfig --region <region> --name <cluster-name>
```

## 다음 단계

1. `ECR`
2. `OIDC / IRSA`
3. `AWS Load Balancer Controller`
4. `Argo CD`
5. `app` 배포

## 주의

- 이 스택은 포트폴리오 기준 1차 베이스입니다.
- 아직 `IRSA`, `ALB Controller`, `external-dns`, `ACM`, `Route53` 는 포함하지 않았습니다.
- EKS 비용은 control plane 자체 비용이 있으므로, 띄워둔 뒤 방치하지 않는 게 중요합니다.
