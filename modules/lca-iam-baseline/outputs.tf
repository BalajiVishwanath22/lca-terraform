output "role_arns" {
  value = { for k, v in aws_iam_role.roles : k => v.arn }
}

output "role_names" {
  value = { for k, v in aws_iam_role.roles : k => v.name }
}
