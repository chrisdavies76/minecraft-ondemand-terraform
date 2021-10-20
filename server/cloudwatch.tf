resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/aws/ecs/${var.name}"
  retention_in_days = var.lambda_log_retention_days
}
