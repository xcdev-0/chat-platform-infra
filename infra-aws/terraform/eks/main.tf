data "aws_availability_zones" "available" {
  state = "available"
}

data "tls_certificate" "cluster_oidc" {
  # IRSA trust policy 에 들어갈 OIDC provider 를 만들기 위해
  # EKS issuer 인증서 지문을 읽어온다.
  url = module.cluster.cluster_oidc_issuer

  depends_on = [module.cluster]
}

locals {
  # 공통 이름 규칙:
  # capstone-dev, capstone-dev-eks 같은 식으로 리소스 이름을 통일한다.
  name         = "${var.project_name}-${var.environment}"
  cluster_name = "${local.name}-eks"

  # 현재 리전에서 사용 가능한 AZ 중 앞에서부터 az_count 개만 사용한다.
  # 1차 버전은 EKS 기본 가용성 구조를 맞추기 위해 최소 2개 AZ 를 전제로 한다.
  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Stack       = "eks"
  }
}

module "network" {
  # EKS 가 올라갈 VPC, public/private subnet, NAT, route table 을 만든다.
  source = "./modules/network"

  name         = local.name
  cluster_name = local.cluster_name
  vpc_cidr     = var.vpc_cidr
  azs          = local.azs
  common_tags  = local.common_tags
}

module "cluster" {
  # EKS control plane 자체를 만든다.
  # 여기서는 managed Kubernetes control plane 과 관련 IAM/log 구성을 다룬다.
  source = "./modules/cluster"

  cluster_name                         = local.cluster_name
  cluster_version                      = var.cluster_version
  subnet_ids                           = module.network.private_subnet_ids
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs
  enabled_cluster_log_types            = var.enabled_cluster_log_types
  cluster_log_retention_days           = var.cluster_log_retention_days
  common_tags                          = local.common_tags
}

module "node_group" {
  # 실제 workload 가 올라갈 worker node 그룹이다.
  # control plane 은 AWS 관리형이고, node group 은 우리가 크기와 인스턴스 타입을 조정한다.
  source = "./modules/node-group"

  cluster_name   = module.cluster.cluster_name
  node_group_name = var.node_group_name
  subnet_ids     = module.network.private_subnet_ids
  instance_types = var.node_group_instance_types
  ami_type       = var.node_group_ami_type
  capacity_type  = var.node_group_capacity_type
  desired_size   = var.node_group_desired_size
  min_size       = var.node_group_min_size
  max_size       = var.node_group_max_size
  disk_size_gib  = var.node_group_disk_size_gib
  common_tags    = local.common_tags
}

# EKS 클러스터의 OIDC issuer를 신뢰하도록 만듬
# OIDC provider로 등록하기
resource "aws_iam_openid_connect_provider" "cluster" {
  url = module.cluster.cluster_oidc_issuer

  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = [
    data.tls_certificate.cluster_oidc.certificates[0].sha1_fingerprint
  ]

  tags = merge(local.common_tags, {
    Name = "${local.cluster_name}-oidc"
  })
}

module "aws_load_balancer_controller_irsa" {
  # 이 role 은 kube-system/aws-load-balancer-controller 
  # ServiceAccount를 쓰는 pod 만 assume 가능하다.
  source = "./modules/irsa-role"

  role_name            = "${local.name}-aws-load-balancer-controller-role"
  oidc_provider_arn    = aws_iam_openid_connect_provider.cluster.arn
  oidc_provider_url    = module.cluster.cluster_oidc_issuer
  namespace            = var.aws_load_balancer_controller_namespace
  service_account_name = var.aws_load_balancer_controller_service_account_name
  policy_json          = file("${path.module}/policies/aws-load-balancer-controller-iam-policy.json")
  common_tags          = local.common_tags
}
