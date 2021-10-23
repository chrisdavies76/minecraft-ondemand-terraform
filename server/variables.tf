variable "name" {
  description = "Name of the server"
  type        = string
}

variable "lambda_log_retention_days" {
  description = "Number of days to keep logs of the lambda function."
  type        = number
  default     = 7
}

variable "sns_notification_emails" {
  description = "Emails to which send an email when the instance starts and stops."
  type        = list(string)
  default     = []
}

variable "startup_minutes" {
  description = "Time to wait before shutting down when server starts but no users connect."
  type        = string
  default     = "10"
}

variable "shutdown_minutes" {
  description = "Time to wait after the last user disconnects before shutting down."
  type        = string
  default     = "20"
}

variable "whitelist" {
  description = "Whitelist as described in https://github.com/itzg/docker-minecraft-server#whitelist-players"
  default     = ""
  type        = string
}

variable "ops" {
  description = "List of server admins."
  type        = string
  default     = ""
}

variable "minecraft_version" {
  description = "Version of Minecraft"
  type        = string
  default     = ""
}

variable "server_type" {
  description = "Server type to use, such as PAPER or SPYGOT"
  type        = string
  default     = ""
}

variable "memory" {
  description = "Memory of the container, in GB"
  type        = number
  default     = 2
}

variable "extra_envs" {
  description = "Extra environment variables to be passed on to the minecraft server container."
  type        = map(string)
  default     = {}
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type = map(string)
  default = {
    For = "minecraft-ondemand"
  }
}

variable "efs_id" {
  description = "ID of the EFS filesystem where to store the game data"
  type        = string
}

variable "subnet_ids" {
  description = "IDs of the subnets to use to host the server."
  type        = list(string)
}

variable "ecs_sg_id" {
  description = "Security group to use with the container"
  type        = string
}

variable "route53_zone_id" {
  description = "ID of the route53 zone to register the server"
  type        = string
}
