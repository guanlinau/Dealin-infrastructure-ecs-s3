locals {
  tag_name = "${var.app_name}-${var.app_environment}"
}

#Create an aws ecr
resource "aws_ecr_repository" "aws_ecr" {
  name = "${local.tag_name}-ecr"
  image_tag_mutability = "IMMUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
    Name        = "${local.tag_name}-ecr"
    Environment = var.app_environment
  }
}
