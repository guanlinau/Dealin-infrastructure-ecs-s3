
resource "aws_s3_bucket" "bucket" {
  bucket = "${var.s3_bucket_name}"
  tags = {
    Name        = "${var.s3_bucket_name}"
    Environment = var.app_environment
  }
}

resource "aws_s3_bucket_website_configuration" "static_website" {
    count = length(keys(var.website)) > 0 ? 1 :0
    bucket = aws_s3_bucket.bucket.id

    dynamic "index_document" {
      for_each = try([var.website["index_document"]],[])
      content {
        suffix = index_document.value
      }
    }

    dynamic "error_document" {
     for_each = try([var.website["error_document"]], [])
      content {
        key=error_document.value
      }
    }

    dynamic "redirect_all_requests_to" {
    for_each = try([var.website["redirect_all_requests_to"]] ,[])
      
      content {
        host_name = redirect_all_requests_to.value
      }
    }
}

resource "aws_s3_bucket_cors_configuration" "cors" {

   count = length(var.cors_rules) > 0 ? 1 :0
   bucket = aws_s3_bucket.bucket.id

   dynamic "cors_rule" {
        for_each = var.cors_rules

        content {
        allowed_headers = try(cors_rule.value.allowed_headers, null)
        allowed_methods = try(cors_rule.value.allowed_methods)
        allowed_origins = try(cors_rule.value.allowed_methods)
        max_age_seconds = try(cors_rule.value.max_age_seconds, null)
        }
   }

}

resource "aws_s3_bucket_versioning" "versioning" {

  count = var.versioning ? 1 : 0
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_ownership_controls" "bucket_ownership_controls" {
  bucket = aws_s3_bucket.bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
  depends_on = [ aws_s3_bucket.bucket,aws_s3_bucket_public_access_block.bucket_public_access_block]
}

resource "aws_s3_bucket_public_access_block" "bucket_public_access_block" {
  # count = var.acl_access_type == "public-read" ? 1 : 0
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = var.acl_access_type == "public-read" ? false : true
  block_public_policy     = var.acl_access_type == "public-read" ? false : true
  ignore_public_acls      = var.acl_access_type == "public-read" ? false : true
  restrict_public_buckets = var.acl_access_type == "public-read" ? false : true
}

resource "aws_s3_bucket_acl" "acl" {
  bucket = aws_s3_bucket.bucket.id
  acl    = var.acl_access_type
  
  depends_on = [aws_s3_bucket_ownership_controls.bucket_ownership_controls]
  
}
