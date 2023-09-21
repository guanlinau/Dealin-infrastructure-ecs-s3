output "loadbalancer_dns_name" {
  value = aws_lb.alb_ecs.dns_name
}

output "loadbalancer_arn" {
  value = aws_lb.alb_ecs.arn
}

output "loadbalancer_zone_id" {
  value = aws_lb.alb_ecs.zone_id
}

output "alb_https_listener" {
  value = aws_lb_listener.https_listener
}

output "target_group_arn" {
  value = aws_lb_target_group.target_group.arn
}