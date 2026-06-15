Terraform
--
This directory contains example Terraform to provision:

- ECR repository
- ECS cluster
- IAM role for ECS task execution
- A Secrets Manager secret for MongoDB connection string

Usage (example):
```bash
cd infra
terraform init
terraform apply \
  -var='aws_region=us-east-1' \
  -var='image=<AWS_ACCOUNT_ID>.dkr.ecr.<REGION>.amazonaws.com/<REPO>:latest' \
  -var='mongodb_secret_arn=arn:aws:secretsmanager:<REGION>:<AWS_ACCOUNT_ID>:secret:<SECRET_NAME>'
```

Or if you already have a secret name instead of an ARN:
```bash
cd infra
terraform init
terraform apply \
  -var='aws_region=us-east-1' \
  -var='image=<AWS_ACCOUNT_ID>.dkr.ecr.<REGION>.amazonaws.com/<REPO>:latest' \
  -var='mongodb_secret_name=<SECRET_NAME>'
```

Note: This is a minimal example. For a production setup you'll need to provision VPC, subnets, security groups, and ECS services/task definitions or import existing ones.

This repo now includes a more complete example which places ECS tasks in private subnets behind an ALB in public subnets. The NAT gateways provide outbound internet access for tasks to pull images or reach external services while keeping tasks non-public.

Important:
- The Terraform creates NAT gateways and EIPs — these incur AWS charges. For testing, consider using a single NAT gateway or enabling a NAT Gateway per AZ as configured.
- Ensure `image` is set to a valid ECR image URI before creating the ECS service.
