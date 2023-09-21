
output "parameters_key_value_pairs" {
  value = {for secret in data.aws_ssm_parameter.secrets : secret.name => secret.value}
}
