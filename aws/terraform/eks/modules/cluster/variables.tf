variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "cluster_version" {
  description = "EKS Kubernetes version"
  type        = string
}

variable "subnet_ids" {
  description = "EKS control plane 에 연결할 subnet IDs"
  type        = list(string)
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "EKS public endpoint 접근 CIDR"
  type        = list(string)
}

variable "enabled_cluster_log_types" {
  description = "EKS control plane log types"
  type        = list(string)
}

variable "cluster_log_retention_days" {
  description = "CloudWatch log retention days"
  type        = number
}

variable "common_tags" {
  description = "공통 태그"
  type        = map(string)
}
