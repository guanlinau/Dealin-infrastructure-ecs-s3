variable "app_environment" {
 type=string
 default = null
}

variable "app_name" {
 type = string
 default = null
}

variable "security_group_alb" {
  type =list(string)
  default = []
}

variable "public_subnets" {
  type = list(any)
  default = []
}

variable "app_port"{
    type=number
    default = null
}

variable "vpc_id" {
  type=string
  default = null
}

variable "deregistration_delay" {
  type=number
  default = null
}

variable "health_check_path" {
  type=string
  default = null
}

variable "certificate_arn" {
  type = string
  default = null
}