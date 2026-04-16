output "role_name" {
  description = "IRSA IAM role name"
  value       = aws_iam_role.this.name
}

output "role_arn" {
  description = "IRSA IAM role ARN"
  value       = aws_iam_role.this.arn
}

output "service_account_subject" {
  description = "Kubernetes ServiceAccount subject used in trust policy"
  value       = local.service_account_subject
}
