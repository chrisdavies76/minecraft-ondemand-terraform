data "archive_file" "ondemand_minecraft_task_starter_lambda_zip" {
  type = "zip"
  source_content = templatefile("${path.module}/lambda/lambda_function.py", {
    aws_region   = data.aws_region.current.name,
    cluster_name = aws_ecs_cluster.minecraft_ondemand_cluster.name,
    service_name = aws_ecs_service.minecraft_ondemand_service.name,
  })
  source_content_filename = "lambda_function.py"
  output_path             = "lambda_function.zip"
}

resource "aws_lambda_function" "ondemand_minecraft_task_starter_lambda" {
  depends_on = [
    aws_cloudwatch_log_group.lambda_function_log_group
  ]
  filename         = "lambda_function.zip"
  function_name    = local.lambda_function_name
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
  source_arn    = "${var.hosted_zone_log_group_arn}:*"
}
