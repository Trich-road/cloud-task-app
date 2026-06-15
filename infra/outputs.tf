output "ecr_repository_url" {
  value = aws_ecr_repository.app.repository_url
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.cluster.name
}

output "mongodb_secret_arn" {
  value = aws_secretsmanager_secret.mongodb.arn
}

output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}

output "ecs_service_name" {
  value = aws_ecs_service.service.name
}

output "task_definition_arn" {
  value = aws_ecs_task_definition.task.arn
}
