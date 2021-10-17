resource "aws_efs_access_point" "minecraft_ondemand_efs_access_point" {
  file_system_id = var.efs_id
  root_directory {
    path = "/${var.name}"
    creation_info {
      owner_uid   = 1000
      owner_gid   = 1000
      permissions = 755
    }
  }
  posix_user {
    uid = 1000
    gid = 1000
  }
  tags = var.common_tags
}
