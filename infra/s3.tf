module "s3" {
  for_each = var.s3_buckets
  source   = "./modules/terraform-aws-s3"

  bucket_name                          = each.key
  is_bucket_website                    = each.value.spec.is_bucket_website
  bucket_website_redirect_all_requests = each.value.spec.redirect_all_requests_to
  source_file_path                     = each.value.spec.source_file_path
  source_file_pattern                  = each.value.spec.source_file_pattern
}

data "aws_iam_policy_document" "allow_cloudfront_origin" {
  for_each = { for k, v in var.s3_buckets : k => v if k == "www.defdev.io" }
  statement {
    effect = "Allow"
    sid    = "AllowCloudFrontOriginWwwDefdevIo"
    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${module.s3[each.key].bucket_arn}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [module.cloudfront[each.key].arn]
    }

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
  }
}

resource "aws_s3_bucket_policy" "allow_cloudfront_origin" {
  for_each = { for k, v in var.s3_buckets : k => v if k == "www.defdev.io" }
  bucket   = module.s3[each.key].bucket_id
  policy   = data.aws_iam_policy_document.allow_cloudfront_origin[each.key].json
}