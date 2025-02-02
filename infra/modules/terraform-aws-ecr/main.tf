resource "aws_ecr_repository" "this" {
  name                 = var.name
  image_tag_mutability = var.is_immutable ? "IMMUTABLE" : "MUTABLE"

  encryption_configuration {
    encryption_type = var.encryption_type
    kms_key         = var.encryption_type == "kms" ? var.kms_key_arn : null
  }
}