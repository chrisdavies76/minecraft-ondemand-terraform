data "aws_route53_zone" "minecraft_ondemand_route53_zone" {
  zone_id = var.route53_zone_id
}

resource "aws_route53_record" "minecraft_ondemand_server_a_record" {
  zone_id = data.aws_route53_zone.minecraft_ondemand_route53_zone.zone_id
  name    = var.name
  type    = "A"
  ttl     = "30"
  records = ["1.1.1.1"]

  lifecycle {
    ignore_changes = [records]
  }
}
