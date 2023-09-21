variable "app_environment" {
 type=string
}

variable "app_name" {
 type = string
}

variable "vpc_cidr_block" {
  type = string
}

variable "private_subnets_cidr_blocks" {
  type = list(string)
}
variable "public_subnets_cidr_blocks" {
  type = list(string)
}



variable "availability_zones" {
type = list(string)
}