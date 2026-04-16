variable "name" {
  description = "리소스 이름 prefix"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name. subnet tag 에 사용"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
}

variable "azs" {
  description = "사용할 AZ 목록"
  type        = list(string)
}

variable "common_tags" {
  description = "공통 태그"
  type        = map(string)
}
