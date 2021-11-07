resource "aws_ecs_cluster" "minecraft_ondemand_cluster" {
  name               = var.cluster_name
  capacity_providers = ["FARGATE_SPOT"]

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}
