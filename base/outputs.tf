output "hosted_zone_nameservers" {
  value = data.aws_route53_zone.minecraft_ondemand_route53_zone.name_servers
}

output "efs_id" {
  value = aws_efs_file_system.minecraft_ondemand_efs.id
}

output "vpc_id" {
  value = aws_default_vpc.default.id
}

output "subnet_ids" {
  value = [
    aws_default_subnet.default_az1.id,
    aws_default_subnet.default_az2.id,
    aws_default_subnet.default_az3.id,
  ]
}

output "ecs_sg_id" {
  value = aws_security_group.allow_minecraft_server_port.id
}

output "hosted_zone_log_group_name" {
  value = aws_cloudwatch_log_group.aws_route53_hosted_zone_log_group.name
}

output "hosted_zone_log_group_arn" {
  value = aws_cloudwatch_log_group.aws_route53_hosted_zone_log_group.arn
}
