module "ecr" {
  for_each = var.ecr_repos
  source   = "./modules/terraform-aws-ecr"

  name         = each.key
  is_immutable = each.value.spec.is_immutable
}