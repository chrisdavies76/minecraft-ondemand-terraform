resource "aws_sns_topic" "minecraft_ondemand_updates_topic" {
  name = "${var.name}-server-updates-topic"
}

resource "aws_sns_topic_subscription" "minecraft_ondemand_updates_topic_email_subscription" {
  count     = length(var.sns_notification_emails)
  topic_arn = aws_sns_topic.minecraft_ondemand_updates_topic.arn
  protocol  = "email"
  endpoint  = var.sns_notification_emails[count.index]
}

resource "aws_iam_policy" "minecraft_ondemand_sns_publish_policy" {
  name        = "${var.name}_ondemand_sns_publish_policy"
  path        = "/"
  description = "Allows the Minecraft server ECS task to send SNS notifications on a specific topic"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "sns:Publish",
        "Resource" : aws_sns_topic.minecraft_ondemand_updates_topic.arn
      }
    ]
  })
  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "minecraft_ondemand_sns_publish_policy_attachment" {
  role       = aws_iam_role.minecraft_ondemand_fargate_task_role.name
  policy_arn = aws_iam_policy.minecraft_ondemand_sns_publish_policy.arn
}
