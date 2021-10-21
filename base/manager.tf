data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-arm64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_key_pair" "manager" {
  key_name   = "manager-key"
  public_key = var.ssh_pub_key
}

resource "aws_instance" "manager" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t4g.nano"

  subnet_id = aws_subnet.manager.id

  key_name = aws_key_pair.manager.key_name

  tags = {
    Name = "Minecraft Manager"
  }

  vpc_security_group_ids = [
    aws_security_group.manager.id
  ]

  user_data = data.cloudinit_config.manager_cloudinit.rendered
}

data "cloudinit_config" "manager_cloudinit" {
  gzip = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content = templatefile(
      "${path.module}/cloudinit/manager.yaml",
      {
        efs_mount_target = aws_efs_mount_target.minecraft_ondemand_efs_mount_target[0].mount_target_dns_name
      }
    )
  }
}

resource "aws_security_group" "manager" {
  name        = "minecraft-manager"
  description = "Allow traffic to the manager"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "Minecraft server port"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = var.common_tags
}

resource "aws_efs_access_point" "minecraft_ondemand_efs_access_point" {
  file_system_id = aws_efs_file_system.minecraft_ondemand_efs.id
  root_directory {
    path = "/"
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
}

resource "aws_security_group" "nfs_from_manager" {
  name        = "nfs_from_minecraft_manager"
  description = "Allow inbound NFS traffic from the Minecraft Manager"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "EFS NFS port"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.manager.id]
  }
}
