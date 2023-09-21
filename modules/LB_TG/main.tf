locals {
  tag_name = "${var.app_name}-${var.app_environment}"
}

# Create application load balancer
resource "aws_lb" "alb_ecs" {
  name               = "${local.tag_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.security_group_alb
  subnets            = [for subnet in var.public_subnets : subnet.id]

  enable_deletion_protection = false
  
  tags = {
    Name        = "${local.tag_name}-alb"
    Environment = var.app_environment
  }
}

#Create target group
resource "aws_lb_target_group" "target_group" {
  name        = "${local.tag_name}-tg"
  port        = var.app_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
  deregistration_delay = var.deregistration_delay
  ip_address_type ="ipv4"

  health_check {
    healthy_threshold   = "3"
    interval            = "300"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "120"
    path                = var.health_check_path
    unhealthy_threshold = "2"
    port = var.app_port
  }

  tags = {
    Name        = "${var.app_name}-tg"
    Environment = var.app_environment
  }
}

#Create 1 listener for 80 and 1 listener for 443
resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.alb_ecs.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  #certification_arn should be updated after the ACM module being created
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }

   tags = {
    Name        = "${var.app_name}-https-listener"
    Environment = var.app_environment
  }
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.alb_ecs.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
   tags = {
    Name        = "${var.app_name}-http-listener"
    Environment = var.app_environment
  }
}