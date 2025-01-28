output "bucket_arn" {
  value = aws_s3_bucket.this.arn
}

output "bucket_id" {
  value = aws_s3_bucket.this.id
}

output "bucket_regional_domain_name" {
  value = aws_s3_bucket.this.bucket_regional_domain_name
}

output "bucket_website_endpoint" {
  value = var.is_bucket_website ? try(aws_s3_bucket_website_configuration.this[0].website_endpoint, null) : null
}