output "task_execution_role_arn" {
  value = aws_iam_role.ecs_tasks_execution_role.arn
}

output "iam_role_policy" {
  value = aws_iam_role_policy_attachment.ecsTaskExecutionRole_policy
}