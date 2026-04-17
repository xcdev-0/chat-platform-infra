resource "aws_cloudwatch_log_group" "this" {
  # EKS control plane 로그를 CloudWatch 로 보낼 log group
  # api, audit, authenticator 같은 로그는 나중에 장애 분석할 때 사용
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = var.cluster_log_retention_days

  tags = merge(var.common_tags, {
    Name = "${var.cluster_name}-logs"
  })
}

resource "aws_iam_role" "this" {
  # EKS control plane 이 AWS 리소스를 다룰 때 사용할 IAM role
  # eks.amazonaws.com 서비스가 assume 하는 role 
  name = "${var.cluster_name}-cluster-role"

  // trust policy
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.cluster_name}-cluster-role"
  })
}

# role에 붙는 permission policy
resource "aws_iam_role_policy_attachment" "cluster_policy" {
  # EKS control plane 기본 운영 권한
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "vpc_resource_controller" {
  # VPC 리소스 연동에 필요한 추가 권한
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

resource "aws_eks_cluster" "this" {
  # 관리형 EKS control plane 생성.
  # worker node 는 별도 node group 모듈에서 만들고,
  # 여기서는 control plane 네트워크와 접근 정책을 정의한다.
  name     = var.cluster_name
  role_arn = aws_iam_role.this.arn
  version  = var.cluster_version

  enabled_cluster_log_types = var.enabled_cluster_log_types

  vpc_config {
    # control plane 이 붙을 subnet 목록.
    # 첫 버전은 private subnet 을 넘겨서 node 와 같은 사설 네트워크 축에 둔다.
    subnet_ids = var.subnet_ids

    # 운영 편의상 public/private endpoint 를 둘 다 켜두되,
    # public endpoint 는 신뢰 가능한 CIDR 로만 제한한다.
    endpoint_public_access  = true
    endpoint_private_access = true
    public_access_cidrs     = var.cluster_endpoint_public_access_cidrs
  }

  # 로그 그룹과 IAM 권한이 준비된 뒤 cluster 를 만들도록 순서를 강제한다.
  depends_on = [
    aws_cloudwatch_log_group.this,
    aws_iam_role_policy_attachment.cluster_policy,
    aws_iam_role_policy_attachment.vpc_resource_controller
  ]

  tags = merge(var.common_tags, {
    Name = var.cluster_name
  })
}
