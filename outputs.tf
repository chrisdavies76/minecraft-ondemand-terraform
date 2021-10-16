output "hosted_zone_nameservers" {
  value = data.aws_route53_zone.minecraft_ondemand_route53_zone.name_servers
}
