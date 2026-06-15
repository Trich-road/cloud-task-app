variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "ecr_repository" {
  description = "ECR repository name"
  type        = string
  default     = "cloud-task-backend"
}

variable "ecs_cluster" {
  description = "ECS cluster name"
  type        = string
  default     = "cloud-task-cluster"
}

variable "project_name" {
  description = "Project name prefix"
  type        = string
  default     = "cloud-task"
}

variable "mongodb_secret_arn" {
  description = "ARN of an existing Secrets Manager secret containing MongoDB URI"
  type        = string
  default     = ""
  validation {
    condition = length(trimspace(var.mongodb_secret_arn)) > 0 || length(trimspace(var.mongodb_secret_name)) > 0
    error_message = "Either mongodb_secret_arn or mongodb_secret_name must be provided."
  }
}

variable "mongodb_secret_name" {
  description = "Name of an existing Secrets Manager secret containing MongoDB URI"
  type        = string
  default     = ""
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "image" {
  description = "Container image URI to deploy"
  type        = string
  default     = ""
}

variable "desired_count" {
  description = "ECS desired count"
  type        = number
  default     = 1
}

variable "min_count" {
  description = "Minimum ECS desired count for autoscaling"
  type        = number
  default     = 1
}

variable "max_count" {
  description = "Maximum ECS desired count for autoscaling"
  type        = number
  default     = 3
}

variable "cpu_target" {
  description = "Target average CPU utilization percentage for autoscaling"
  type        = number
  default     = 50
}
