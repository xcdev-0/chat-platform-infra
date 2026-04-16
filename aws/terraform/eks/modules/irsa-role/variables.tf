variable "role_name" {
  description = "IRSA IAM role name"
  type        = string
}

variable "oidc_provider_arn" {
  description = "IAM OIDC provider ARN used by EKS"
  type        = string
}

variable "oidc_provider_url" {
  description = "EKS cluster OIDC issuer URL"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace for the ServiceAccount"
  type        = string
}

variable "service_account_name" {
  description = "Kubernetes ServiceAccount name"
  type        = string
}

variable "policy_json" {
  description = "Custom IAM policy JSON attached to this role"
  type        = string
  default     = ""
}

variable "managed_policy_arns" {
  description = "Additional managed policy ARNs attached to this role"
  type        = list(string)
  default     = []
}

variable "common_tags" {
  description = "Common AWS tags"
  type        = map(string)
  default     = {}
}
