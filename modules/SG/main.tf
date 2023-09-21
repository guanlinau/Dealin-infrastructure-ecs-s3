locals {
  tag_name = "${var.app_name}-${var.app_environment}"
}
resource "aws_security_group" "alb_sg" {
  name        = "${local.tag_name}-alb-sg"
  description = "enable http/https access on port 80/443"
  vpc_id      = var.vpc_id

   ingress {
    description      = "Https traffic access"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Http traffic access"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = "${local.tag_name}-alb-sg"
    Environment = var.app_environment
  }
}

resource "aws_security_group" "ecs_sg" {
  name        = "${local.tag_name}-ecs-sg"
  description = "enable httprequest through load balancer security group ${aws_security_group.alb_sg.name} access on port ${var.app_port} "
  vpc_id      = var.vpc_id

  ingress {
    description      = "Http traffic access"
    from_port        = var.app_port
    to_port          = var.app_port
    protocol         = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = "${local.tag_name}-ecs-sg"
    Environment = var.app_environment
  }
}