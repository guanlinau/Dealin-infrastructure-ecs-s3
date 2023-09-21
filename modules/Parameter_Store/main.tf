
locals {
  tag_name = "${var.app_name}-${var.app_environment}"
}

resource "aws_ssm_parameter" "secrets" {
  for_each = var.task_definition_container_env_values
  name        = each.key
#   key_id = "xxx"
  type        = "SecureString"
  value       = each.value

  tags = {
    Name        = "${local.tag_name}-${each.key}-parameter"
    Environment = var.app_environment
  }
}

#Get variable values from parameters store for task definition's environment variables

data "aws_ssm_parameter" "secrets" {
  for_each = var.task_definition_container_env_values
	name = each.key
	with_decryption = true

  depends_on = [ aws_ssm_parameter.secrets ]
}

