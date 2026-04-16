locals {
  # IAM trust policy 조건 키는 https:// 를 뺀 issuer host/path 형식을 쓴다.
  oidc_provider_host      = replace(var.oidc_provider_url, "https://", "")
  service_account_subject = "system:serviceaccount:${var.namespace}:${var.service_account_name}"
}

resource "aws_iam_role" "this" {
  # 특정 ServiceAccount 를 쓰는 pod 만 assume 할 수 있는 IRSA role
  name = var.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = var.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${local.oidc_provider_host}:sub" = local.service_account_subject
            "${local.oidc_provider_host}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = var.role_name
  })
}

resource "aws_iam_policy" "this" {
  count = var.policy_json != "" ? 1 : 0

  # pod 가 실제로 호출할 AWS API 권한 정의
  name   = "${var.role_name}-policy"
  policy = var.policy_json

  tags = merge(var.common_tags, {
    Name = "${var.role_name}-policy"
  })
}

resource "aws_iam_role_policy_attachment" "custom" {
  count = var.policy_json != "" ? 1 : 0

  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this[0].arn
}

resource "aws_iam_role_policy_attachment" "managed" {
  for_each = toset(var.managed_policy_arns)

  role       = aws_iam_role.this.name
  policy_arn = each.value
}
