variable "app_environment" {

}

variable "region" {
  
}

variable "app_name" {

}

variable "ecr_repo" {
  
}

variable "cpu" {

}

variable "memory" {

}

variable "app_port" {

}


variable "task_execution_role_arn" {
  
}
variable "desired_service_num" {


}

variable "target_group_arn" {

}

variable "private_subnet_ids" {

}

variable "security_groups_ecs" {

}

variable "alb_listener" {

}

variable "ecs_depends_iam_role_policy" {

}


variable "parameters_key_value_pairs" {
  type = map(string)
  default = {}
}