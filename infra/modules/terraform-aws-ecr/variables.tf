variable "name" {
  type = string
}

variable "is_immutable" {
  type    = bool
  default = false
}

variable "encryption_type" {
  type    = string
  default = "AES256"
}

variable "kms_key_arn" {
  type    = string
  default = null
}

variable "repo_policy_document" {
  type    = string
  default = null
}