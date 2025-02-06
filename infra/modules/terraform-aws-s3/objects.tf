locals {
  content_type = {
    css  = "text/css"
    html = "text/html"
    jpeg = "image/jpeg"
    js = "text/javascript"
    json = "application/json"
    map  = "text/css"
    png  = "image/png"
    scss = "text/plain"
    svg  = "image/svg+xml"
  }
}

resource "aws_s3_object" "this" {
  for_each = var.source_file_path != null ? fileset(var.source_file_path, var.source_file_pattern) : toset([])

  content_type           = local.content_type[reverse(split(".", each.value))[0]]
  key                    = each.value
  bucket                 = aws_s3_bucket.this.id
  source                 = "${var.source_file_path}/${each.value}"
  source_hash            = filemd5("${var.source_file_path}/${each.value}")
  server_side_encryption = "AES256"
}