resource "aws_ecs_cluster" "minecraft_ondemand_cluster" {
  name               = var.name
  capacity_providers = ["FARGATE_SPOT"]

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  tags = var.common_tags
}

resource "aws_ecs_task_definition" "minecraft_ondemand_task" {
  family             = "${var.name}-server"
  task_role_arn      = aws_iam_role.minecraft_ondemand_fargate_task_role.arn
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  memory = 1024 * (var.memory + 1)
  cpu    = 1024

  container_definitions = jsonencode([
    {
      name      = "minecraft-server"
      image     = "itzg/minecraft-server"
      essential = false
      portMappings = [
        {
          containerPort = 25565
          hostPort      = 25565
        }
      ]
      environment = [
        {
          name  = "EULA"
          value = "TRUE"
        },
        {
          name  = "VERSION"
          value = var.minecraft_version
        },
        {
          name  = "MEMORY"
          value = "${var.memory}G"
        },
        {
          name  = "TYPE"
          value = var.server_type
        },
        {
          name  = "OPS"
          value = var.ops
        },
        {
          name  = "WHITELIST"
          value = var.whitelist
        },
        {
          name  = "ENFORCE_WHITELIST"
          value = "true"
        }
      ]
      mountPoints = [
        {
          sourceVolume  = "data"
          containerPath = "/data"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group = aws_cloudwatch_log_group.ecs.name
          awslogs-region = data.aws_region.current.name
          awslogs-stream-prefix = "minecraft-server"
        }
      }
    },
    {
      name      = "minecraft-ecsfargate-watchdog"
      image     = "doctorray/minecraft-ecsfargate-watchdog"
      essential = true
      environment = [
        {
          name  = "CLUSTER"
          value = aws_ecs_cluster.minecraft_ondemand_cluster.name
        },
        {
          name  = "SERVICE"
          value = local.ecs_service_name
        },
        {
          name  = "DNSZONE"
          value = data.aws_route53_zone.minecraft_ondemand_route53_zone.id
        },
        {
          name  = "SERVERNAME"
          value = local.hostname
        },
        {
          name  = "SNSTOPIC"
          value = aws_sns_topic.minecraft_ondemand_updates_topic.arn
        },
        {
          name  = "STARTUPMIN"
          value = var.startup_minutes
        },
        {
          name  = "SHUTDOWNMIN"
          value = var.shutdown_minutes
        }
      ]
      mountPoints = [
        {
          sourceVolume  = "data"
          containerPath = "/data"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group = aws_cloudwatch_log_group.ecs.name
          awslogs-region = data.aws_region.current.name
          awslogs-stream-prefix = "ecsfargate-watchdog"
        }
      }
    }
  ])

  volume {
    name = "data"
    efs_volume_configuration {
      file_system_id     = var.efs_id
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = aws_efs_access_point.minecraft_ondemand_efs_access_point.id
        iam             = "ENABLED"
      }
    }
  }
}

resource "aws_ecs_service" "minecraft_ondemand_service" {
  name            = local.ecs_service_name
  cluster         = aws_ecs_cluster.minecraft_ondemand_cluster.id
  task_definition = aws_ecs_task_definition.minecraft_ondemand_task.arn
  desired_count   = 0

  depends_on = [aws_iam_role_policy_attachment.minecraft_ondemand_efs_access_policy_attachment]

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
  }

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [var.ecs_sg_id]
    assign_public_ip = true
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}
