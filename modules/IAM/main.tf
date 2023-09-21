#Create IAM role for ecs

locals {
  tag_name = "${var.app_name}-${var.app_environment}"
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    sid     = ""
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_tasks_execution_role" {
  name               = "${local.tag_name}-ECSTaskExecutionrole"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  tags = {
    Name        = "${local.tag_name}-iam-role"
    Environment = var.app_environment
  }
}

data "aws_iam_policy_document" "policy" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams",
      "logs:DescribeLogGroups",
      "cloudwatch:PutMetricData",
      "ssm:GetParameter"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "policy" {
  name        = "AmazonECSTaskExecutionRolePolicy"
  description = "AmazonECSTaskExecutionRolePolicy"
  policy      = data.aws_iam_policy_document.policy.json
  tags = {
    Name        = "${local.tag_name}-iam-policy"
    Environment = var.app_environment
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecs_tasks_execution_role.name
  policy_arn = aws_iam_policy.policy.arn
}