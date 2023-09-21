variable "domain_name" {
  description = "The root domain name"
  type =string
}

variable "subdomain_name" {
  description = "The subdomain name"
  type = string
}

variable "record_type" {
  description = "The type of your record, such as A record, AAAA record or CNAME record etc."
  type =string
}
variable "alb_dns_name" {
  type = string
  description = "The domain name of alb, cloudfront or s3"
}

variable "alb_zone_id" {
  description = "The hosted zone id of the alb, cloudfornt or s3"
  type = string
}

