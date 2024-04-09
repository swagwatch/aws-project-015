# outputs.tf

output "external_dns_iam_policy_role_name" {
  value = aws_iam_policy.external_dns_iam_policy.name
}

output "external_dns_iam_policy_role_arn" {
  value = aws_iam_policy.external_dns_iam_policy.arn
}

output "internal_dns_iam_policy_role_name" {
  value = aws_iam_policy.internal_dns_iam_policy.name
}

output "internal_dns_iam_policy_role_arn" {
  value = aws_iam_policy.internal_dns_iam_policy.arn
}

output "cert_manager_iam_policy_role_name" {
  value = aws_iam_policy.cert_manager_iam_policy.name
}

output "cert_manager_iam_policy_role_arn" {
  value = aws_iam_policy.cert_manager_iam_policy.arn
}

output "team_black_namespace_iam_policy_name" {
  value = aws_iam_policy.team_black_namespace_iam_policy.name
}

output "team_black_namespace_iam_policy_arn" {
  value = aws_iam_policy.team_black_namespace_iam_policy.arn
}

output "team_green_namespace_iam_policy_name" {
  value = aws_iam_policy.team_green_namespace_iam_policy.name
}

output "team_green_namespace_iam_policy_arn" {
  value = aws_iam_policy.team_green_namespace_iam_policy.arn
}

output "team_white_namespace_iam_policy_name" {
  value = aws_iam_policy.team_white_namespace_iam_policy.name
}

output "team_white_namespace_iam_policy_arn" {
  value = aws_iam_policy.team_white_namespace_iam_policy.arn
}

output "eks_managed_node_groups" {
  value = module.eks.eks_managed_node_groups
}