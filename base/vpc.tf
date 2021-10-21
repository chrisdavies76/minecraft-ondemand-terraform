resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "Minecraft"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Minecraft"
  }
}

resource "aws_route" "main" {
  route_table_id         = aws_vpc.main.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_subnet" "main" {
  count = length(data.aws_availability_zones.available.names)

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 3, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  map_public_ip_on_launch = true

  tags = {
    Name = "Minecraft public ${data.aws_availability_zones.available.names[count.index]}"
  }
}

resource "aws_subnet" "manager" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 3, 3)
  availability_zone = data.aws_availability_zones.available.names[0]

  map_public_ip_on_launch = true

  tags = {
    Name = "Minecraft manager"
  }
}

resource "aws_security_group" "allow_minecraft_server_port" {
  name        = "minecraft_server_port"
  description = "Allow inbound traffic to the Minecraft server port"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "Minecraft server port"
    from_port        = 25565
    to_port          = 25565
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
