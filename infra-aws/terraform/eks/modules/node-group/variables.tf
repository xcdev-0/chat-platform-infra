variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "subnet_ids" {
  description = "Node group subnet IDs"
  type        = list(string)
}

variable "node_group_name" {
  description = "Managed node group name"
  type        = string
}

variable "instance_types" {
  description = "Managed node group instance types"
  type        = list(string)
}

variable "ami_type" {
  description = "Managed node group AMI type"
  type        = string
}

variable "capacity_type" {
  description = "ON_DEMAND 또는 SPOT"
  type        = string
}

variable "desired_size" {
  description = "Desired node count"
  type        = number
}

variable "min_size" {
  description = "Min node count"
  type        = number
}

variable "max_size" {
  description = "Max node count"
  type        = number
}

variable "disk_size_gib" {
  description = "Node root disk size"
  type        = number
}

variable "common_tags" {
  description = "공통 태그"
  type        = map(string)
}
