variable "app_environment" {
  type =string
  default = null
}
variable "app_name" {
  type =string
  default = null
 
}

variable "domain_name" {
  type =string
  default = null
}

variable "validation_method" {
  description = "Which method to use for validation. DNS or EMAIL are valid, NONE can be used for certifications imported outside"
  type = string
  default = "DNS"

  validation {
    condition = contains(["DNS","EMAIL","NONE"], var.validation_method)
    error_message = "Valid values are DNS, EMAIL or NONE"
  }
}

variable "key_algorithm" {
  description = "Specifies the algorithm of the public and private key pair that your Amazon issued certificate uses to encrypt data. 'RSA_2048', 'EC_prime256v1' or 'EC_secp384r1' are valid"
  type = string
  default = "RSA_2048"

  validation {
    condition = contains(["RSA_2048", "EC_prime256v1", "EC_secp384r1"], var.key_algorithm)
    error_message = "Valid values are 'RSA_2048', 'EC_prime256v1' or 'EC_secp384r1'"
  }
}