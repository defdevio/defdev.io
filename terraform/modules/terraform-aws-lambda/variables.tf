variable "concurrent_executions" {
  type    = number
  default = 5
}

variable "function_name" {
  type = string
}

variable "iam_role_arn" {
  type = string
}

variable "image_uri" {
  type = string
}
