provider "aws" {
  region = var.aws_region
}

resource "aws_ecr_repository" "app" {
  name = var.ecr_repository
}

resource "aws_ecs_cluster" "cluster" {
  name = var.ecs_cluster
}

data "aws_iam_policy" "ecs_execution" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "task_execution_role" {
  name = "${var.ecs_cluster}-task-exec-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = { Service = "ecs-tasks.amazonaws.com" }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "exec_attach" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = data.aws_iam_policy.ecs_execution.arn
}

data "aws_secretsmanager_secret" "mongodb" {
  count = length(trimspace(var.mongodb_secret_name)) > 0 ? 1 : 0
  name  = var.mongodb_secret_name
}

locals {
  mongodb_secret_arn = length(trimspace(var.mongodb_secret_arn)) > 0 ? var.mongodb_secret_arn : data.aws_secretsmanager_secret.mongodb[0].arn
}

resource "aws_cloudwatch_log_group" "ecs_exec" {
  name              = "/ecs/${var.project_name}-exec"
  retention_in_days = 14
}
