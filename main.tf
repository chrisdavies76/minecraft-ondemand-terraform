terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      version = "~> 4.0"
    }
  }
}

data "aws_route53_zone" "minecraft" {
  name = "rootfest.com"
}

module "minecraft_common" {
  source          = "./base"
  route53_zone_id = data.aws_route53_zone.minecraft.id
  ssh_pub_key     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDdZgewyrf1blJF4Qs2YzdTGOHaD8jE7ytOAP2ymsiheUZOcU3WRWfKPRIRaR4heCeubhfFYkYsND1/pOLejMT+D0g/klpyw/wcAr3cSk1EwJBu60a9g/4c4hTzKaUEjI/o/23yKsiPqM6dzDWf8bje6LLcQNi60J4a5aJKPe0XDl1h79vjhuLhkp7c3S0Vvl8kgxy+PXOE3Lqdql1SLtc/2paS/rpslSfqTlsEjOIz7KTaKrQXTpf5Y8oWGJdthNFzy4aDAqTJD8wRJan9SVDxSVDVxnAZ/+6kyioGF1ViCJelHiWQ5BTapK2mlD1EAYn5ASh81I1JmXgwnq7HLS0iCH+sjVeZP8TzPZPuHazeYyXptPOLKQGb6uE/M2dngSf7De/aPWihZy4pzdutHLtfY9/xksPdn4rmo7xHoYbW5OHNXkqwRetykjrzJlc6mUf0PAJCJAIT7LKsJW6v81sslEekop979RR3gtD6CLId3YnzxbWHgPPnOm8D9lA7s+U= chris@Chriss-Mac-mini.local"
  cluster_name    = "minecraft"
}

module "minecraft_server1" {
  source = "./server"
  name   = "minecraft"
  # sns_notification_emails = ["address@example.com"]
  minecraft_version = "1.17.1"
  server_type       = "PAPER"
  ops               = "y0da2024"

  # Check the env variables that are available here:
  # https://github.com/itzg/docker-minecraft-server/blob/master/README.md
  extra_envs = {
    SPAWN_PROTECTION = "0"
    MOTD             = "My awesome server!!"
  }

  route53_zone_id = data.aws_route53_zone.minecraft.id
  efs_id          = module.minecraft_common.efs_id
  subnet_ids      = module.minecraft_common.subnet_ids
  ecs_sg_id       = module.minecraft_common.ecs_sg_id
  cluster_name    = "minecraft"
  cluster_arn     = module.minecraft_common.cluster_arn
}
