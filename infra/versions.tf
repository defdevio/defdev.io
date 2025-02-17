terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.84.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.51.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.12.1"
    }
  }
  required_version = "~>1.10"
}