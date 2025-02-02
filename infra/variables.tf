variable "lambda_functions" {
  default     = {}
  description = "A map of Lambda Functions specs."

  type = map(object({
    spec = object({
      ecr = object({
        is_immutable = optional(bool, false)
        image_tag    = string
      })
    })
  }))
}

variable "s3_buckets" {
  default     = {}
  description = "A map of S3 bucket definitions."

  type = map(object({
    spec = object({
      is_bucket_website   = optional(bool, false)
      source_file_path    = optional(string, null)
      source_file_pattern = optional(string, null)

      redirect_all_requests_to = optional(map(object({
        protocol = string
      })), {})
    })
  }))
}