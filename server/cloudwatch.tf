resource "aws_cloudwatch_log_subscription_filter" "minecraft_ondemand_route53_query_log_filter" {
  provider = aws.us-east-1

  depends_on = [
    aws_lambda_permission.allow_cloudwatch,
    var.hosted_zone_log_group_arn,
  ]
  name            = "${var.name}_ondemand"
  log_group_name  = var.hosted_zone_log_group_name
  filter_pattern  = local.hostname
  destination_arn = aws_lambda_function.ondemand_minecraft_task_starter_lambda.arn
}

resource "aws_cloudwatch_log_group" "lambda_function_log_group" {
  name              = "/aws/lambda/${local.lambda_function_name}"
  retention_in_days = var.lambda_log_retention_days
}

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/aws/ecs/${local.hostname}"
  retention_in_days = var.lambda_log_retention_days
}
