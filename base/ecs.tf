resource "aws_ecs_cluster" "minecraft_ondemand_cluster" {
  name               = var.cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_cluster_capacity_providers" "minecraft_ondemand_cluster" {
  cluster_name = aws_ecs_cluster.minecraft_ondemand_cluster.name

  capacity_providers = ["FARGATE_SPOT"]
}
