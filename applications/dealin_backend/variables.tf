variable "region" {
  type    = string
  default = "ap-southeast-2"
}
variable "app_environment" {
  type    = string
  default = "UAT"
}

variable "stack" {
  type    = string
  default = "api"
}

variable "vpc_cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "private_subnets_cidr_blocks" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}
variable "public_subnets_cidr_blocks" {
  type    = list(string)
  default = ["10.0.3.0/24", "10.0.4.0/24"]
}


variable "availability_zones" {
  type    = list(string)
  default = ["ap-southeast-2a", "ap-southeast-2b"]
}

variable "cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  type        = number
  default     = 1024
}

variable "memory" {
  description = "Fargate instance memory to provision (in MiB)"
  type        = number
  default     = 2048
}

variable "app_port" {
  type    = number
  default = 3000
}

variable "desired_service_num" {
  type    = number
  default = 1

}

variable "lb_deregistration_waiting_time" {
  type    = number
  default = 0
}

variable "health_check_path" {
  type    = string
  default = "/"
}

variable "domain_name" {
  type    = string
  default = "jingkangau.com"
}

variable "task_definition_container_env_values" {
  description = "Map of parameter names and their values"
  type        = map(string)
  default     = {}
}

# Variables for ACM-amazon certificate manager module 

variable "validation_method" {
  description = "Which method to use for validation. DNS or EMAIL are valid, NONE can be used for certifications imported outside"
  type        = string
  default     = "DNS"

  validation {
    condition     = contains(["DNS", "NONE"], var.validation_method)
    error_message = "Valid values are DNS or NONE"
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

# variables for route 53 record
variable "record_type" {
  description = "The type of your record, such as A record, AAAA record or CNAME record etc."
  type        = string
}