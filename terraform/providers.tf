provider "aws" {
  region = "us-west-2"
}

provider "aws" {
  alias  = "east"
  region = "us-east-1"
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}