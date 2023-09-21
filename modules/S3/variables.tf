
variable "app_environment" {
  type =string
  default = null
}

variable "s3_bucket_name" {
  description = "Name for the S3 bucket"
  type        = string
  validation {
    condition     = can(regex("^([a-z0-9])+(-[a-z0-9]+)*$", var.s3_bucket_name)) && length(var.s3_bucket_name) >= 3 && length(var.s3_bucket_name) <= 63
    error_message = "The S3 bucket name must be between 3 and 63 characters, start and end with a lowercase letter or number, and can include lowercase letters, numbers, and single hyphens between characters."
  }
}

variable "website" {
  type = map(string)
  default = {}
}

variable "cors_rules" {
    type = list(any)
    default = []  
}

variable "versioning" {
  type= bool
  default = false
}

variable "acl_access_type" {
  description = "Access type for the resource"
  type        = string
  default = "private"

  validation {
    condition     = var.acl_access_type == "private" || var.acl_access_type == "public-read"
    error_message = "The access_type must be either 'private' or 'public-read'."
  }
}
