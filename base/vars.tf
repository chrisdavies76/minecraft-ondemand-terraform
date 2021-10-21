variable "route53_zone_id" {
  type = string
}

variable "route53_log_retention_days" {
  type    = number
  default = 7
}

variable "common_tags" {
  default = {
    For = "minecraft-ondemand"
  }
}

variable "lambda_log_retention_days" {
  type    = number
  default = 7
}

variable "ssh_pub_key" {
  type = string
}
