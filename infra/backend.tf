terraform {
  backend "s3" {
    bucket = "terraform-defdev-io"
    key    = "terraform/terraform.tfstate"
    region = "us-west-2"
  }
}