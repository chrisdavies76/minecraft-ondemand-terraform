variable "name" {
  description = "Name of the server"
  type        = string
}

variable "lambda_log_retention_days" {
  type    = number
  default = 7
}

variable "sns_notification_emails" {
  type    = list(string)
  default = []
}

variable "startup_minutes" {
  type    = string
  default = "10"
}

variable "shutdown_minutes" {
  type    = string
  default = "20"
}

variable "whitelist" {
  description = "Whitelist as described in https://github.com/itzg/docker-minecraft-server#whitelist-players"
  default     = ""
  type        = string
}

variable "ops" {
  type        = string
  description = "Server admins"
  default     = ""
}

variable "minecraft_version" {
  type        = string
  description = "Version of Minecraft"
  default     = ""
}

variable "server_type" {
  type        = string
  description = "Server type to use, such as PAPER or SPYGOT"
  default     = ""
}

variable "memory" {
  type        = number
  description = "Memory of the container, in GB"
  default     = 2
}

variable "extra_envs" {
  type    = map(string)
  default = {}
}

variable "common_tags" {
  default = {
    For = "minecraft-ondemand"
  }
}

variable "efs_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "ecs_sg_id" {
  type = string
}

variable "route53_zone_id" {
  type = string
}

variable "hosted_zone_log_group_name" {
  type = string
}

variable "hosted_zone_log_group_arn" {
  type = string
}
