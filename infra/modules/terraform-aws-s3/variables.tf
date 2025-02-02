variable "bucket_name" {
  type        = string
  description = "The name of the bucket."
}

variable "bucket_website_error_document_key" {
  type    = string
  default = null
}

variable "bucket_website_index_document_suffix" {
  type    = string
  default = null
}

variable "bucket_website_redirect_all_requests" {
  default = {}

  type = map(object({
    protocol = string
  }))
}

variable "is_bucket_website" {
  type    = bool
  default = false
}

variable "source_file_pattern" {
  type        = string
  default     = null
  description = "The file source pattern to target the files for upload."
}

variable "source_file_path" {
  type    = string
  default = null
}

variable "tags" {
  type        = map(string)
  description = "The tags to apply to the bucket."
  default = {
    "owner" = "defdev.io"
  }
}