variable "s3_buckets" {
  default     = {}
  description = "A map of S3 bucket definitions."

  type = map(object({
    source_file_pattern = optional(string, null)
  }))
}