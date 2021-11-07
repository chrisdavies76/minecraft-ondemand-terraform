data "archive_file" "ondemand_minecraft_task_starter_lambda_zip" {
  type = "zip"
  source_content = templatefile("${path.module}/lambda/lambda_function.py", {
    aws_region   = data.aws_region.current.name,
    cluster_name = var.cluster_name,
  })
  source_content_filename = "lambda_function.py"
  output_path             = "lambda_function.zip"
}

resource "aws_lambda_function" "ondemand_minecraft_task_starter_lambda" {
  depends_on = [
    aws_cloudwatch_log_group.lambda_function_log_group
  ]
  filename         = "lambda_function.zip"
  function_name    = "minecraft_dns_lambda"
  role             = aws_iam_role.ondemand_minecraft_task_starter_lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  source_code_hash = data.archive_file.ondemand_minecraft_task_starter_lambda_zip.output_base64sha256
  runtime          = "python3.9"
  tags             = var.common_tags
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ondemand_minecraft_task_starter_lambda.function_name
  principal     = "logs.us-east-1.amazonaws.com"
  source_arn    = "${aws_cloudwatch_log_group.aws_route53_hosted_zone_log_group.arn}:*"
}

resource "aws_iam_role" "ondemand_minecraft_task_starter_lambda_role" {
  name = "ondemand_minecraft_task_starter_lambda_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "minecraft_ondemand_ecs_control_policy" {
  name        = "minecraft_ondemand_ecs_control_policy"
  path        = "/"
  description = "Allows the Minecraft server ECS task to understand which network interface is attached to it in order to properly update the DNS records"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ecs:*"
        ],
        "Resource" : [
          "arn:aws:ecs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:service/*",
          "arn:aws:ecs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:task/*"
        ]
      }
    ]
  })
  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "minecraft_ondemand_ecs_control_policy_attachment_lambda" {
  role       = aws_iam_role.ondemand_minecraft_task_starter_lambda_role.name
  policy_arn = aws_iam_policy.minecraft_ondemand_ecs_control_policy.arn
}

resource "aws_iam_role_policy_attachment" "minecraft_ondemand_lambda_cloudwatch_logging_policy_attachment" {
  role       = aws_iam_role.ondemand_minecraft_task_starter_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
