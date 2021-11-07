terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      version = "~> 3.0"
    }
  }
}

resource "aws_route53_zone" "minecraft" {
  name = "example.com"
}

module "minecraft_common" {
  source          = "./base"
  route53_zone_id = aws_route53_zone.minecraft.id
  ssh_pub_key     = "your ssh pub key here"
  cluster_name    = "minecraft"
}

module "minecraft_server1" {
  source = "./server"
  name   = "minecraft"
  # sns_notification_emails = ["address@example.com"]
  minecraft_version = "1.17.1"
  server_type       = "PAPER"
  ops               = "your_mc_username_here"

  # Check the env variables that are available here:
  # https://github.com/itzg/docker-minecraft-server/blob/master/README.md
  extra_envs = {
    SPAWN_PROTECTION = "0"
    MOTD             = "My awesome server!!"
  }

  route53_zone_id = aws_route53_zone.minecraft.id
  efs_id          = module.minecraft_common.efs_id
  subnet_ids      = module.minecraft_common.subnet_ids
  ecs_sg_id       = module.minecraft_common.ecs_sg_id
  cluster_name    = "minecraft"
  cluster_arn     = module.minecraft_common.cluster_arn
}
