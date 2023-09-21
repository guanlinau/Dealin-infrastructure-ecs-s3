variable "task_definition_container_env_values" {
  description = "Map of parameter names and their values"
  type        = map(string)
  default     = {}
}

variable "app_environment" {
 type=string
 default = null
}

variable "app_name" {
 type = string
 default = null
}
