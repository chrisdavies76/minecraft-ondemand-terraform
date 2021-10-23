variable "route53_zone_id" {
  description = "ID of the route53 zone to use."
  type        = string
}

variable "route53_log_retention_days" {
  description = "Number of days to keep route53 logs."
  type        = number
  default     = 7
}

variable "common_tags" {
  description = "Common tags for all resources."
  type        = map(string)
  default = {
    For = "minecraft-ondemand"
  }
}

variable "lambda_log_retention_days" {
  description = "Number of days to keep logs."
  type        = number
  default     = 7
}

variable "ssh_pub_key" {
  description = "SSH public key used to access the manager instance."
  type        = string
}
