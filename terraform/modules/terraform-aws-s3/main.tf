resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
  tags   = var.tags
}

resource "aws_s3_bucket_acl" "this" {
  bucket = aws_s3_bucket.this.id
  acl    = "private"
}

resource "aws_s3_object" "this" {
  for_each               = try(fileset(path.module, var.source_file_pattern), null)
  key                    = reverse(split("/", each.value))[0]
  bucket                 = aws_s3_bucket.this.id
  source                 = each.value
  source_hash            = filemd5(each.value)
  server_side_encryption = "AES256"
}