locals {
  ecs_service_name     = "${var.name}-server"
  lambda_function_name = "ondemand_${var.name}_task_starter_lambda"
  hostname             = "${var.name}.${data.aws_route53_zone.minecraft_ondemand_route53_zone.name}"
}
