resource "aws_route53_zone" "minecraft" {
  name = "example.com"
}

module "minecraft_common" {
  source = "./base"
  route53_zone_id = aws_route53_zone.minecraft.id
}

module "minecraft_server1" {
  source     = "./server"
  name = "minecraft"
  sns_notification_email = "address@example.com"
  minecraft_version = "1.17.1"
  server_type = "PAPER"
  ops = "your_mc_username_here"

  route53_zone_id = aws_route53_zone.minecraft.id
  efs_id = module.minecraft_common.efs_id
  subnet_ids = module.minecraft_common.subnet_ids
  ecs_sg_id = module.minecraft_common.ecs_sg_id
  hosted_zone_log_group_name = module.minecraft_common.hosted_zone_log_group_name
  hosted_zone_log_group_arn = module.minecraft_common.hosted_zone_log_group_arn
}