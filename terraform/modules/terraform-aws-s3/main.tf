resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
  tags   = var.tags
}

resource "aws_s3_object" "this" {
  for_each               = var.source_file_path != null ? fileset(var.source_file_path, var.source_file_pattern) : toset([])
  key                    = each.value
  bucket                 = aws_s3_bucket.this.id
  source                 = "${var.source_file_path}/${each.value}"
  source_hash            = filemd5("${var.source_file_path}/${each.value}")
  server_side_encryption = "AES256"
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