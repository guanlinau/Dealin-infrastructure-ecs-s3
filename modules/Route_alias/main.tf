# retrieve the hosted zone of the domain name
data "aws_route53_zone" "selected" {
  name         = var.domain_name
}

#Create a alias record in route 53
resource "aws_route53_record" "alias_record" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = var.subdomain_name
  type    = var.record_type

  alias {
    name                   = var.name
    zone_id                = var.zone_id
    evaluate_target_health = true
  }
}