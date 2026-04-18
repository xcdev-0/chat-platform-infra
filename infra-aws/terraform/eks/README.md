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
6. `OIDC provider`
7. `aws-load-balancer-controller` 용 `IRSA role`
8. `kubectl` 연결용 output

## 파일 구조

```text
eks
├── .gitignore
├── main.tf
├── outputs.tf
├── policies
├── providers.tf
├── terraform.tfvars.example
├── variables.tf
├── versions.tf
└── modules
    ├── cluster
    ├── irsa-role
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
- 기본 instance type 은 `t3.small`
- 기본 AMI 는 `AL2023_x86_64_STANDARD`

지금은 `x86_64` 를 기본으로 둡니다.  
이유는 현재 Jenkins 파이프라인이 기본적으로 `amd64` 이미지를 만들고 있고, 프론트 `kaniko` 빌드를 멀티 아키텍처로 확장하는 비용이 큽니다.

즉 1차 포트폴리오 기준에서는:
- EKS node group 은 `t3.small` + `x86_64`
- Jenkins 빌드 산출물도 `amd64`

로 맞춰서 경로를 단순하게 가져가는 편이 낫습니다.

## 버전 기준

기본 `cluster_version` 은 `1.33` 으로 잡았습니다.  
이 값은 2026-04-15 기준 Amazon EKS 표준 지원 버전 목록 안에 있는 버전입니다.  
공식 문서: https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html

## 사용 순서

```bash
cd code/infra/infra-aws/terraform/eks

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

1. `AWS Load Balancer Controller`
2. `Ingress -> ALB`
3. `ECR`
4. `Argo CD`
5. `app` 배포

## 주의

- 이 스택은 포트폴리오 기준 1차 베이스입니다.
- `OIDC / IRSA` 까지는 포함되어 있습니다.
- 아직 `AWS Load Balancer Controller` 설치, `external-dns`, `ACM`, `Route53` 는 포함하지 않았습니다.
- EKS 비용은 control plane 자체 비용이 있으므로, 띄워둔 뒤 방치하지 않는 게 중요합니다.
