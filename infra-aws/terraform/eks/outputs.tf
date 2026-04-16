output "cluster_name" {
  description = "EKS cluster name"
  value       = module.cluster.cluster_name
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.cluster.cluster_endpoint
}

output "cluster_version" {
  description = "EKS cluster Kubernetes version"
  value       = module.cluster.cluster_version
}

output "cluster_oidc_issuer" {
  description = "EKS cluster OIDC issuer URL"
  value       = module.cluster.cluster_oidc_issuer
}

output "cluster_oidc_provider_arn" {
  description = "IAM OIDC provider ARN used for IRSA"
  value       = aws_iam_openid_connect_provider.cluster.arn
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.network.private_subnet_ids
}

output "configure_kubectl_command" {
  description = "kubectl context 설정 명령"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.cluster.cluster_name}"
}

output "aws_load_balancer_controller_role_arn" {
  description = "IRSA role ARN for aws-load-balancer-controller ServiceAccount"
  value       = module.aws_load_balancer_controller_irsa.role_arn
}
