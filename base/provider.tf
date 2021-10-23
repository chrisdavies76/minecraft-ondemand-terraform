terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      version = "~> 3.0"
    }
    archive = {
      version = "~> 2.2"
    }
    cloudinit = {
      version = "~> 2.2"
    }
  }
}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}
