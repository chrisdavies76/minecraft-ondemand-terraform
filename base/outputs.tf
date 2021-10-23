output "efs_id" {
  value       = aws_efs_file_system.minecraft_ondemand_efs.id
  description = "ID of the EFS filesystem."
}

output "vpc_id" {
  value       = aws_vpc.main.id
  description = "ID of the VPC."
}

output "subnet_ids" {
  value       = aws_subnet.main.*.id
  description = "IDs of the subnets."
}

output "ecs_sg_id" {
  value       = aws_security_group.allow_minecraft_server_port.id
  description = "ID of the ECS security group for the MC servers."
}
