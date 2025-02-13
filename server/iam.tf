resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.name}EcsTaskExecutionRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "ecs_task_exec_role_policy_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "minecraft_ondemand_fargate_task_role" {
  name = "ecs.task.${var.name}-server"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
  tags = var.common_tags
}

data "aws_efs_file_system" "main" {
  file_system_id = var.efs_id
}

resource "aws_iam_policy" "minecraft_ondemand_efs_access_policy" {
  name        = "${var.name}_ondemand_efs_access_policy"
  path        = "/"
  description = "Allows Read Write access to the Minecraft server EFS"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite",
          "elasticfilesystem:DescribeFileSystems"
        ],
        "Resource" : data.aws_efs_file_system.main.arn,
        "Condition" : {
          "StringEquals" : {
            "elasticfilesystem:AccessPointArn" : aws_efs_access_point.minecraft_ondemand_efs_access_point.arn
          }
        }
      }
    ]
  })
  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "minecraft_ondemand_efs_access_policy_attachment" {
  role       = aws_iam_role.minecraft_ondemand_fargate_task_role.name
  policy_arn = aws_iam_policy.minecraft_ondemand_efs_access_policy.arn
}

resource "aws_iam_policy" "minecraft_ondemand_ecs_control_policy" {
  name        = "${var.name}_ondemand_ecs_control_policy"
  path        = "/"
  description = "Allows the Minecraft server ECS task to understand which network interface is attached to it in order to properly update the DNS records"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ecs:*"
        ],
        "Resource" : [
          aws_ecs_service.minecraft_ondemand_service.id,
          "arn:aws:ecs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:task/${var.cluster_name}/*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:DescribeNetworkInterfaces"
        ],
        "Resource" : [
          "*"
        ]
      }
    ]
  })
  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "minecraft_ondemand_ecs_control_policy_attachment" {
  role       = aws_iam_role.minecraft_ondemand_fargate_task_role.name
  policy_arn = aws_iam_policy.minecraft_ondemand_ecs_control_policy.arn
}

resource "aws_iam_policy" "minecraft_ondemand_route53_update_policy" {
  name        = "${var.name}_ondemand_route53_update_policy"
  path        = "/"
  description = "Allows the Minecraft server ECS task to update DNS records on a hosted zone"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "route53:GetHostedZone",
          "route53:ChangeResourceRecordSets",
          "route53:ListResourceRecordSets"
        ],
        "Resource" : data.aws_route53_zone.minecraft_ondemand_route53_zone.arn
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "route53:ListHostedZones"
        ],
        "Resource" : "*"
      }
    ]
  })
  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "minecraft_ondemand_route53_update_policy_attachment" {
  role       = aws_iam_role.minecraft_ondemand_fargate_task_role.name
  policy_arn = aws_iam_policy.minecraft_ondemand_route53_update_policy.arn
}
