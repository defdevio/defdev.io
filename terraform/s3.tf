module "s3" {
  for_each            = var.s3_buckets
  source              = "./modules/terraform-aws-s3"
  bucket_name         = each.key
  source_file_pattern = each.value.source_file_pattern
}