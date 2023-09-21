
locals {
  tag_name = "${var.app_name}-${var.app_environment}"
  container_definition_env_vars_list = [for k, v in var.parameters_key_value_pairs : {name=k, value=v}]

}

#Create ECS cluster
resource "aws_kms_key" "ecs-kms-key" {
  description             = "${local.tag_name}-ecs_kms_key"
  deletion_window_in_days = 7
  is_enabled              = true
  #   enable_key_rotation=true
  tags = {
    Name        = "${local.tag_name}-kms_key"
    Environment = var.app_environment
  }
}

resource "aws_kms_alias" "ecs-kms-key-alias" {
  name          = "alias/${local.tag_name}-key"
  target_key_id = aws_kms_key.ecs-kms-key.key_id
}

resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name = "${local.tag_name}-logs"
  tags = {
    Name        = "${local.tag_name}-logs"
    Environment = var.app_environment
  }
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${local.tag_name}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  configuration {
    execute_command_configuration {
      kms_key_id = aws_kms_key.ecs-kms-key.arn
      logging    = "OVERRIDE"

      log_configuration {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.ecs_log_group.name
      }
    }
  }

  tags = {
    Name        = "${local.tag_name}-ecs"
    Environment = var.app_environment
  }
}

#Create task definition
resource "aws_ecs_task_definition" "aws_ecs_task_df" {
  family = "${local.tag_name}-task"

  container_definitions = jsonencode([
    {
      name = "${local.tag_name}-container"
      # image = "${var.ecr_repo}"
      image = "044530424430.dkr.ecr.ap-southeast-2.amazonaws.com/dealin:1.0.0"
      environment = local.container_definition_env_vars_list
      
      essential = true
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group = "${aws_cloudwatch_log_group.ecs_log_group.id}"
          awslogs-region = var.region
          awslogs-stream-prefix ="${local.tag_name}"
        }
      }
      portMappings = [
        {
          containerPort =var.app_port
          hostPort =var.app_port
          protocol = "tcp"
          appProtocol = "http"
        }
      ],
      networkMode = "awsvpc"
      dependsOn: [{
				containerName: "aws-otel-collector"
				condition: "START"
			}]
    },
    {
			name: "aws-otel-collector"
			image: "public.ecr.aws/aws-observability/aws-otel-collector:v0.30.0"
			essential: true
			command: [
				"--config=/etc/ecs/ecs-cloudwatch.yaml"
			]
			logConfiguration: {
				logDriver: "awslogs"
				options: {
					awslogs-create-group: "True"
					awslogs-group: "/ecs/ecs-aws-otel-sidecar-collector"
					awslogs-region: var.region
					awslogs-stream-prefix: "${local.tag_name}"
				}
			}
		}
  ])
  
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = var.memory
  cpu                      = var.cpu
  execution_role_arn       = var.task_execution_role_arn
  task_role_arn            = var.task_execution_role_arn

  tags = {
    Name        = "${local.tag_name}-ecs-td"
    Environment = var.app_environment
  }
}

resource "aws_service_discovery_http_namespace" "example" {
  name        = "ecs"
}

# Create ecs service
resource "aws_ecs_service" "ecs_service" {
  name                = "${local.tag_name}-service"
  cluster             = aws_ecs_cluster.ecs_cluster.id
  task_definition     = aws_ecs_task_definition.aws_ecs_task_df.arn
  desired_count       = var.desired_service_num
  launch_type         = "FARGATE"
  scheduling_strategy = "REPLICA"
  deployment_circuit_breaker {
    enable =true
    rollback = true
  }
  # wait_for_steady_state =true
  # force_new_deployment = true

  network_configuration {
    subnets          = var.private_subnet_ids
    assign_public_ip = false
    security_groups  = var.security_groups_ecs
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "${local.tag_name}-container"
    container_port   = var.app_port
  }

  service_connect_configuration {
    enabled = true
    namespace = aws_service_discovery_http_namespace.example.arn
    log_configuration {
      log_driver = "awslogs"
        options = {
          awslogs-create-group: "True"
					awslogs-group: "ecs-service-logs"
          awslogs-region = var.region
          awslogs-stream-prefix ="${local.tag_name}"
        }
    }
  }

  tags = {
    Name        = "${local.tag_name}-ecs-service"
    Environment = var.app_environment
  }

  depends_on = [var.ecs_depends_iam_role_policy, var.alb_listener]
}

#Configure autoscaling

resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 3
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.ecs_cluster.name}/${aws_ecs_service.ecs_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

   tags = {
    Name        = "${local.tag_name}-ecs-auto-scale"
    Environment = var.app_environment
  }
}

resource "aws_appautoscaling_policy" "ecs_policy_memory" {
  name               = "${local.tag_name}-memory-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value = 60
    disable_scale_in =false
    scale_in_cooldown =60
  }
}

resource "aws_appautoscaling_policy" "ecs_policy_cpu" {
  name               = "${local.tag_name}-cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value = 60
    disable_scale_in =false
    scale_in_cooldown =60
  }
}