provider "aws" {
  region = "us-west-2"
}

provider "aws" {
  alias  = "east"
  region = "us-east-1"
}

data "aws_secretsmanager_secret" "cloudflare" {
  name = "cloudflare"
}

ephemeral "aws_secretsmanager_secret_version" "cloudflare" {
  secret_id = data.aws_secretsmanager_secret.cloudflare.arn
}

provider "cloudflare" {
  api_token = jsondecode(ephemeral.aws_secretsmanager_secret_version.cloudflare.secret_string)["cloudflare_api_token"]
}