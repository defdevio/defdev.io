module "s3" {
  for_each = var.s3_buckets
  source   = "./modules/terraform-aws-s3"

  bucket_name                          = each.key
  is_bucket_website                    = each.value.is_bucket_website
  bucket_website_redirect_all_requests = each.value.redirect_all_requests_to
  source_file_path                     = each.value.source_file_path
  source_file_pattern                  = each.value.source_file_pattern
}
