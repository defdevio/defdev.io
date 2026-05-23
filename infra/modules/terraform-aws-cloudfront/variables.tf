variable "acm_certificate_arn" {
  type = string
}

variable "aliases" {
  type    = list(string)
  default = []
}

variable "default_root_object" {
  type    = string
  default = "index.html"
}

variable "domain_name" {
  type = string
}

variable "origin_access_control" {
  default = null

  type = object({
    name             = string
    description      = string
    origin_type      = string
    signing_behavior = optional(string, "always")
    signing_protocol = optional(string, "sigv4")
  })
}

variable "origin_id" {
  type = string
}
