data "aws_caller_identity" "this" {}
data "aws_region" "this" {}

locals {
  aws_account_id = data.aws_caller_identity.this.account_id
  aws_region     = data.aws_region.this.id
}