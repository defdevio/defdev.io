variable "domain" {
  type    = string
  default = null
}

variable "email_identities" {
  type    = list(string)
  default = []
}

variable "iam_role_id" {
  type = string
}