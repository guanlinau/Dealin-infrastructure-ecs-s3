
# # Query the hosted zone_id of the root domain name
data "aws_route53_zone" "selected" {
  count = var.app_environment == "pro" ? 1 : 0
  name  = var.web_domain_name
}
# # Create a CNAME for production environment only
resource "aws_route53_record" "CNAME_record" {
  count   = var.app_environment == "pro" ? 1 : 0
  zone_id = data.aws_route53_zone.selected[0].zone_id
  name    = "www.${var.web_domain_name}"
  type    = "CNAME"
  ttl     = "300"
  records = [var.web_domain_name]
}

# module "cloudfront_route_record_www" {
#   count          = var.app_environment == "pro" ? 1 : 0
#   source         = "./modules/Route_alias"
#   domain_name    = var.web_domain_name
#   subdomain_name = "www.${var.web_domain_name}"
#   record_type    = var.record_type
#   name           = module.cloudfront.cloudfront_domain_name
#   zone_id        = module.cloudfront.cloudfront_hosted_zone_id
# }


# Create a alias name for cloudfront distribution domain name
module "cloudfront_route_record" {
  source         = "../../modules/Route_alias"
  domain_name    = var.web_domain_name
  subdomain_name = var.app_environment == "pro" ? var.web_domain_name : "${var.app_environment}.${var.web_domain_name}"
  record_type    = var.record_type
  name           = module.cloudfront.cloudfront_domain_name
  zone_id        = module.cloudfront.cloudfront_hosted_zone_id
}

module "s3_bucket" {
  source          = "../../modules/S3"
  app_environment = var.app_environment
  #  cloudfront_distribution_id = module.cloudfront.cloudfront_id
  s3_bucket_name  = var.s3_bucket_name
  website         = var.website
  cors_rules      = var.cors_rules
  versioning      = var.versioning
  acl_access_type = var.acl_access_type
}

module "cloudfront" {
  source                          = "../../modules/CloudFront"
  bucket_regional_domain_name              = module.s3_bucket.bucket_regional_domain_name
  s3_bucket_id                    = module.s3_bucket.s3_bucket_id
  cf_acm_certificate_arn          = module.cloudfront_acm.certificate_arn
  cloudfront_alias_name           = var.app_environment == "pro" ? ["www.${var.web_domain_name}", var.web_domain_name] : ["${var.app_environment}.${var.web_domain_name}"]
  cloudfront_origin_shield_region = var.region
  app_environment                 = var.app_environment
  cloudfront_origin_shield        = var.cloudfront_origin_shield
  cf_default_cache_min_ttl        = var.cf_default_cache_min_ttl
  cf_default_cache_max_ttl        = var.cf_default_cache_max_ttl
  cf_default_cache_default_ttl    = var.cf_default_cache_default_ttl
  cf_viewer_protocol_policy       = var.cf_viewer_protocol_policy
  cf_price_class                  = var.cf_price_class
  cf_restriction_type             = var.cf_restriction_type
  cf_restriction_locations        = var.cf_restriction_locations

  depends_on = [module.s3_bucket]

}

module "cloudfront_acm" {
  source = "../../modules/ACM"
  providers = {
    aws = aws.us_east_1_region
  }
  app_environment   = var.app_environment
  app_name          = var.app_name
  domain_name       = var.web_domain_name
  validation_method = var.validation_method
  key_algorithm     = var.key_algorithm
}

# Create a s3 bucket for storing front-end environment, it is private!
module "s3_bucket_env" {
  source          = "../../modules/S3"
  app_environment = var.app_environment
  s3_bucket_name  = var.app_environment == "pro" ? "pro-${var.s3_bucket_name_env}" : "uat-${var.s3_bucket_name_env}"
  website         = {}
  cors_rules      = []
  versioning      = var.versioning
  acl_access_type = "private"
}

# Attach OAC policy to s3 bucket
resource "aws_s3_bucket_policy" "s3_bucket_access_policy" {
  bucket = module.s3_bucket.s3_bucket_id
  policy = data.aws_iam_policy_document.this.json
}

data "aws_iam_policy_document" "this" {
  version = "2012-10-17"
  statement {
    sid = "AllowCloudFrontServicePrincipalReadOnly"
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${module.s3_bucket.bucket_arn}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [module.cloudfront.cloudfront_arn]
    }
  }
}