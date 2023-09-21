### terraform.tfvars sample

```
region                         = "ap-southeast-2"
app_environment                = "uat"
app_name                       = "dealin"
vpc_cidr_block                 = "10.0.0.0/16"
private_subnets_cidr_blocks    = ["10.0.1.0/24", "10.0.2.0/24"]
public_subnets_cidr_blocks     = ["10.0.3.0/24", "10.0.4.0/24"]
availability_zones             = ["ap-southeast-2a", "ap-southeast-2b"]
cpu                            = 1024
memory                         = 2048
app_port                       = 3000
desired_service_num            = 2
lb_deregistration_waiting_time = 2
health_check_path              = "/"
domain_name                    = "jingkangau.com"


#这个parameters的值需要存到terraform cloud或者jenkins中
task_definition_container_env_values = {
  "CONNECTION_STRING" = "value1"
}


```

## Further update

### cs service 那边 考虑设置 alarm，设置 roll back

### create s3 bucket module
