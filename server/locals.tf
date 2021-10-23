locals {
  hostname = "${var.name}.${data.aws_route53_zone.minecraft_ondemand_route53_zone.name}"
}
