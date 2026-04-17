variable "project_name" {
  description = "리소스 이름 prefix 에 사용할 프로젝트 이름"
  type        = string
  default     = "capstone"
}

variable "environment" {
  description = "배포 환경 이름"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS 리전"
  type        = string
  default     = "ap-northeast-2"
}

variable "az_count" {
  description = "사용할 AZ 개수. EKS 는 최소 2개 권장"
  type        = number
  default     = 2

  validation {
    condition     = var.az_count >= 2
    error_message = "az_count 는 최소 2 이상이어야 합니다."
  }
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.40.0.0/16"
}

variable "cluster_version" {
  description = "EKS Kubernetes minor version"
  type        = string
  default     = "1.33"
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "EKS public API endpoint 접근 CIDR"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enabled_cluster_log_types" {
  description = "CloudWatch 로 보낼 EKS control plane log 유형"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "cluster_log_retention_days" {
  description = "EKS control plane log retention days"
  type        = number
  default     = 7
}

variable "node_group_instance_types" {
  description = "Managed node group 인스턴스 타입"
  type        = list(string)
  default     = ["t4g.medium"]
}

variable "node_group_name" {
  description = "Managed node group 이름"
  type        = string
  default     = "capstone-dev-eks-small"
}

variable "node_group_ami_type" {
  description = "Managed node group AMI type"
  type        = string
  default     = "AL2023_ARM_64_STANDARD"
}

variable "node_group_capacity_type" {
  description = "ON_DEMAND 또는 SPOT"
  type        = string
  default     = "ON_DEMAND"
}

variable "node_group_desired_size" {
  description = "Managed node group desired size"
  type        = number
  default     = 2
}

variable "node_group_min_size" {
  description = "Managed node group min size"
  type        = number
  default     = 2
}

variable "node_group_max_size" {
  description = "Managed node group max size"
  type        = number
  default     = 3
}

variable "node_group_disk_size_gib" {
  description = "Managed node group root disk size"
  type        = number
  default     = 40
}

variable "aws_load_balancer_controller_namespace" {
  description = "Namespace for aws-load-balancer-controller ServiceAccount"
  type        = string
  default     = "kube-system"
}

variable "aws_load_balancer_controller_service_account_name" {
  description = "ServiceAccount name for aws-load-balancer-controller"
  type        = string
  default     = "aws-load-balancer-controller"
}
