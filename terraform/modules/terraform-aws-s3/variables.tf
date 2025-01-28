variable "bucket_name" {
  type        = string
  description = "The name of the bucket."
}

variable "source_file_pattern" {
  type        = string
  default     = null
  description = "The file source pattern to target the files for upload."
}

variable "tags" {
  type        = map(string)
  description = "The tags to apply to the bucket."
  default = {
    "owner" = "defdev.io"
  }
}