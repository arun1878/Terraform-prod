output "codedeploy_app" {
  description = "CodeDeploy application"
  value = aws_codedeploy_app.app.name
}

output "codedeploy_service_role" {
  description = "CodeDeploy group service role"
  value = aws_iam_role.role.arn
}