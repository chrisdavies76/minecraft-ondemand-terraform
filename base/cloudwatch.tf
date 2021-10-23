resource "aws_cloudwatch_log_group" "aws_route53_hosted_zone_log_group" {
  provider = aws.us-east-1

  name              = "/aws/route53/${data.aws_route53_zone.minecraft_ondemand_route53_zone.name}"
  retention_in_days = var.route53_log_retention_days
}

resource "aws_cloudwatch_log_resource_policy" "route53_query_logging_policy" {
  provider = aws.us-east-1

  policy_document = data.aws_iam_policy_document.route53_query_logging_policy.json
  policy_name     = "route53-query-logging-policy"
}

data "aws_iam_policy_document" "route53_query_logging_policy" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["${aws_cloudwatch_log_group.aws_route53_hosted_zone_log_group.arn}:*"]

    principals {
      identifiers = ["route53.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_cloudwatch_log_subscription_filter" "minecraft_ondemand_route53_query_log_filter" {
  provider = aws.us-east-1

  depends_on = [
    aws_lambda_permission.allow_cloudwatch,
    aws_cloudwatch_log_group.aws_route53_hosted_zone_log_group,
  ]
  name            = "minecraft_ondemand"
  log_group_name  = aws_cloudwatch_log_group.aws_route53_hosted_zone_log_group.name
  filter_pattern  = data.aws_route53_zone.minecraft_ondemand_route53_zone.name
  destination_arn = aws_lambda_function.ondemand_minecraft_task_starter_lambda.arn
}

resource "aws_cloudwatch_log_group" "lambda_function_log_group" {
  name              = "/aws/lambda/${data.aws_route53_zone.minecraft_ondemand_route53_zone.name}"
  retention_in_days = var.lambda_log_retention_days
}
