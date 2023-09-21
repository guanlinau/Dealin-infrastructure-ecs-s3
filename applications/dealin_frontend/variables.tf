
variable "region" {
  description = "The default region"
  type        = string
  default     = null
}

variable "us_east_1_region" {
  description = "This region is used for issuing acm needed by clondfront"
  type        = string
  default     = "us-east-1"
}
variable "app_environment" {
  description = "The environment, such as uat, dev or production"
  type        = string
  default     = null
}

variable "app_name" {
  description = "The name of your app"
  type        = string
  default     = null
}

variable "web_domain_name" {
  description = "The domain name"
  type        = string
  default     = null
}
# Variables for s3 bucket
variable "s3_bucket_name" {
  description = "Name for the S3 bucket"
  type        = string
  validation {
    condition     = can(regex("^([a-z0-9])+(-[a-z0-9]+)*$", var.s3_bucket_name)) && length(var.s3_bucket_name) >= 3 && length(var.s3_bucket_name) <= 63
    error_message = "The S3 bucket name must be between 3 and 63 characters, start and end with a lowercase letter or number, and can include lowercase letters, numbers, and single hyphens between characters."
  }
}

variable "website" {
  description = "The html page of your static website, such a index.html or 404.html"
  type        = map(string)
  default     = {}
}

variable "cors_rules" {
  type    = list(any)
  default = []
}

variable "versioning" {
  description = "Weather to enable s3 bucket versioning or not"
  type        = bool
  default     = false
}

variable "acl_access_type" {
  description = "Access type for the resource"
  type        = string
  default     = "private"

  validation {
    condition     = var.acl_access_type == "private" || var.acl_access_type == "public-read"
    error_message = "The access_type must be either 'private' or 'public-read'."
  }
}

# Variables for cloudfornt
variable "cloudfront_origin_shield" {
  description = "Weather to enable origin shield or not"
  type        = bool
  default     = false
}

variable "cf_default_cache_min_ttl" {
  description = "The default cache min ttl"
  type        = number
  default     = 0
}
variable "cf_default_cache_max_ttl" {
  description = "The default cache max ttl"
  type        = number
  default     = 86400
}
variable "cf_default_cache_default_ttl" {
  description = "The default cache default ttl"
  type        = number
  default     = 3600
}

variable "cf_viewer_protocol_policy" {
  type    = string
  default = "redirect-to-https"

  validation {
    condition     = contains(["allow-all", "https-only", "redirect-to-https"], var.cf_viewer_protocol_policy)
    error_message = "The my_variable value must be 'allow-all', 'https-only', 'redirect-to-https'."
  }
}

variable "cf_price_class" {
  description = "The areas that you want to distrubute your cdn"
  type        = string
  default     = "PriceClass_All"
  validation {
    condition     = contains(["PriceClass_All", "PriceClass_200", "PriceClass_100"], var.cf_price_class)
    error_message = "The my_variable value must be 'PriceClass_All', 'PriceClass_200', 'PriceClass_100'."
  }
}

variable "cf_restriction_type" {
  type    = string
  default = "none"
  validation {
    condition     = contains(["none", "whitelist", "blacklist"], var.cf_restriction_type)
    error_message = "The my_variable value must be 'none', 'whitelist', 'blacklist'."
  }
}

variable "cf_restriction_locations" {
  type    = list(string)
  default = []
}


# Variables for ACM
variable "validation_method" {
  description = "Which method to use for validation. DNS or EMAIL are valid, NONE can be used for certifications imported outside"
  type        = string
  default     = "DNS"

  validation {
    condition     = contains(["DNS", "EMAIL", "NONE"], var.validation_method)
    error_message = "Valid values are DNS, EMAIL or NONE"
  }
}

variable "key_algorithm" {
  description = "Specifies the algorithm of the public and private key pair that your Amazon issued certificate uses to encrypt data. 'RSA_2048', 'EC_prime256v1' or 'EC_secp384r1' are valid"
  type        = string
  default     = "RSA_2048"

  validation {
    condition     = contains(["RSA_2048", "EC_prime256v1", "EC_secp384r1"], var.key_algorithm)
    error_message = "Valid values are 'RSA_2048', 'EC_prime256v1' or 'EC_secp384r1'"
  }

}


# Variables for route 53 record
variable "record_type" {
  type        = string
  description = "The type of the record, like A, CNAME, AAAA, etc"
}


# Variable for s3 bucket used to store front-end environment variables
variable "s3_bucket_name_env" {
  description = "The name of the s3 bucket used to store front-end environment variables"
  type        = string
}