resource "aws_efs_file_system" "minecraft_ondemand_efs" {
  tags = var.common_tags
}

resource "aws_efs_backup_policy" "policy" {
  file_system_id = aws_efs_file_system.minecraft_ondemand_efs.id

  backup_policy {
    status = "ENABLED"
  }
}

resource "aws_efs_mount_target" "minecraft_ondemand_efs_mount_target" {
  count = length(aws_subnet.main)

  file_system_id = aws_efs_file_system.minecraft_ondemand_efs.id
  subnet_id      = aws_subnet.main[count.index].id
  security_groups = [
    aws_security_group.nfs_from_minecraft.id,
    aws_security_group.nfs_from_manager.id,
  ]
}

resource "aws_security_group" "nfs_from_minecraft" {
  name        = "nfs_from_minecraft"
  description = "Allow inbound NFS traffic from the Minecraft servers"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "EFS NFS port"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.allow_minecraft_server_port.id]
  }

  tags = var.common_tags
}
