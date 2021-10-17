resource "aws_cloudwatch_log_group" "aws_route53_hosted_zone_log_group" {
  provider = aws.us-east-1

  name              = "/aws/route53/${data.aws_route53_zone.minecraft_ondemand_route53_zone.name}"
  retention_in_days = var.route53_log_retention_days
}

resource "aws_cloudwatch_log_resource_policy" "route53_query_logging_policy" {
  provider = aws.us-east-1

  policy_document = data.aws_iam_policy_document.route53-query-logging-policy.json
  policy_name     = "route53-query-logging-policy"
}

data "aws_iam_policy_document" "route53-query-logging-policy" {
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
