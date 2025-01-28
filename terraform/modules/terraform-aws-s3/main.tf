resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
  tags   = var.tags
}

resource "aws_s3_bucket_website_configuration" "this" {
  count  = var.is_bucket_website ? 1 : 0
  bucket = aws_s3_bucket.this.id

  dynamic "error_document" {
    for_each = var.bucket_website_error_document_key != null ? [1] : []
    content {
      key = var.bucket_website_error_document_key
    }
  }

  dynamic "index_document" {
    for_each = var.bucket_website_index_document_suffix != null ? [1] : []
    content {
      suffix = var.bucket_website_index_document_suffix
    }
  }

  dynamic "redirect_all_requests_to" {
    for_each = var.bucket_website_redirect_all_requests
    content {
      host_name = redirect_all_requests_to.key
      protocol  = redirect_all_requests_to.value.protocol
    }
  }
}