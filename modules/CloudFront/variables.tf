variable "cloudfront_origin_shield_region" {
  type = string
  default = "ap-southeast-2"
}

variable "app_environment" {
  type =string
  default = null
}

variable "s3_bucket_id" {
  type = string
  default = null
}

variable "bucket_regional_domain_name" {
  type =string
  default = null
}
variable "cloudfront_alias_name" {
  type = list(string)
  default = []
}

variable "cloudfront_origin_shield" {
    type = bool
    default = false
}

variable "cf_default_cache_min_ttl" {
    type = number
    default = 0
}
variable "cf_default_cache_max_ttl" {
    type = number
    default = 86400
}
variable "cf_default_cache_default_ttl" {
    type = number
    default = 3600
}

variable "cf_viewer_protocol_policy" {
  type = string
  default = "redirect-to-https"

  validation {
    condition     = contains(["allow-all", "https-only", "redirect-to-https"], var.cf_viewer_protocol_policy)
    error_message = "The my_variable value must be 'allow-all', 'https-only', 'redirect-to-https'."
  }
}

variable "cf_price_class" {
  type = string
  default = "PriceClass_All"
  validation {
    condition = contains(["PriceClass_All", "PriceClass_200", "PriceClass_100"], var.cf_price_class)
    error_message = "The my_variable value must be 'PriceClass_All', 'PriceClass_200', 'PriceClass_100'."
  }
}

variable "cf_restriction_type" {
  type = string
  default = "none"
  validation {
    condition = contains(["none","whitelist","blacklist"], var.cf_restriction_type)
    error_message = "The my_variable value must be 'none', 'whitelist', 'blacklist'."
  }
}

variable "cf_restriction_locations" {
  type = list(string)
  default = []
}

variable "cf_acm_certificate_arn" {
  type = string
  default = null
}