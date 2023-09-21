locals {
  tag_name = "${var.stack}-${var.app_environment}"
}

module "vpc" {
  source                      = "../../modules/VPC"
  app_environment             = var.app_environment
  app_name                    = var.stack
  vpc_cidr_block              = var.vpc_cidr_block
  private_subnets_cidr_blocks = var.private_subnets_cidr_blocks
  public_subnets_cidr_blocks  = var.public_subnets_cidr_blocks
  availability_zones          = var.availability_zones

}

module "iam" {
  source          = "../../modules/IAM"
  app_environment = var.app_environment
  app_name        = var.stack

}
module "parameters" {
  source                               = "../../modules/Parameter_Store"
  app_environment                      = var.app_environment
  app_name                             = var.stack
  task_definition_container_env_values = var.task_definition_container_env_values
}

module "security_groups" {
  source = "../../modules/SG"

  app_environment = var.app_environment
  app_name        = var.stack
  app_port        = var.app_port
  vpc_id          = module.vpc.vpc_id

}

module "acm" {
  source            = "../../modules/ACM"
  app_environment   = var.app_environment
  app_name          = var.stack
  domain_name       = var.domain_name
  validation_method = var.validation_method
  key_algorithm     = var.key_algorithm
}

module "loadbalancer_tg" {
  source               = "../../modules/LB_TG"
  app_environment      = var.app_environment
  app_name             = var.stack
  app_port             = var.app_port
  deregistration_delay = var.lb_deregistration_waiting_time
  health_check_path    = var.health_check_path

  security_group_alb = [module.security_groups.alb_sg_id]
  public_subnets     = module.vpc.public_subnets
  vpc_id             = module.vpc.vpc_id
  certificate_arn    = module.acm.certificate_arn

  depends_on = [module.acm]

}

module "route" {
  source         = "../../modules/Route_53"
  domain_name    = var.domain_name
  subdomain_name = var.app_environment == "pro" ? "api.${var.domain_name}" : "${var.app_environment}-api.${var.domain_name}"
  alb_dns_name   = module.loadbalancer_tg.loadbalancer_dns_name
  alb_zone_id    = module.loadbalancer_tg.loadbalancer_zone_id
  record_type    = var.record_type
  depends_on     = [module.loadbalancer_tg]
}

module "ecr" {
  source          = "../../modules/ECR"
  app_environment = var.app_environment
  app_name        = var.stack
}

module "ecs" {
  source              = "../../modules/ECS"
  region              = var.region
  app_environment     = var.app_environment
  app_name            = var.stack
  cpu                 = var.cpu
  memory              = var.memory
  app_port            = var.app_port
  desired_service_num = var.desired_service_num

  parameters_key_value_pairs  = module.parameters.parameters_key_value_pairs
  private_subnet_ids          = [for subnet in module.vpc.private_subnets : subnet.id]
  task_execution_role_arn     = module.iam.task_execution_role_arn
  ecs_depends_iam_role_policy = module.iam.iam_role_policy
  ecr_repo                    = module.ecr.ecr_repo_url
  security_groups_ecs         = [module.security_groups.ecs_sg_id]
  target_group_arn            = module.loadbalancer_tg.target_group_arn
  alb_listener                = module.loadbalancer_tg.alb_https_listener
  depends_on                  = [module.ecr, module.iam, module.vpc, module.parameters, module.loadbalancer_tg]
}

