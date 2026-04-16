output "node_group_name" {
  description = "Managed node group name"
  value       = aws_eks_node_group.this.node_group_name
}

output "node_role_arn" {
  description = "Managed node role ARN"
  value       = aws_iam_role.this.arn
}
