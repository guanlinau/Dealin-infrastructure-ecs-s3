locals {
  tag_name = "${var.app_name}-${var.app_environment}"
}

data "aws_route53_zone" "selected" {
  name         = "${var.domain_name}"
  private_zone = false
}

resource "aws_acm_certificate" "acm" {
  domain_name       = "${var.domain_name}"
  subject_alternative_names = ["www.${var.domain_name}", "*.${var.domain_name}"]
  validation_method = var.validation_method
  key_algorithm =var.key_algorithm

  tags = {
    Name        = "${local.tag_name}-acm"
    Environment = var.app_environment
  }

  lifecycle {
    create_before_destroy =true
  }
}

resource "aws_route53_record" "records" {
  for_each = {
    for dvo in aws_acm_certificate.acm.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.selected.zone_id

  depends_on = [ aws_acm_certificate.acm ]
}

resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.acm.arn
  validation_record_fqdns = [for record in aws_route53_record.records : record.fqdn]
}