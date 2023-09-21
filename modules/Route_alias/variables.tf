variable domain_name {
    type = string
    default = null
    description = "The root domain name"
}

variable "subdomain_name" {
  type = string
  default = null
  description = "The record name, also is the subdomain name you want to create"
}

variable "record_type" {
  type = string
  description = "The type of the record, like A, CNAME, AAAA, etc"
}

variable "name" {
  type = string
  default = null
  description = "The name of your resource record, like dns domain name of your cdn, s3, ELB"
}

variable "zone_id" {
  type = string
  default = null
  description = "The hosted zone for a cdn, s3, elb or route 53 hosted zone"
}