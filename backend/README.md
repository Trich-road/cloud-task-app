# Backend API

Simple tasks REST API for demos and cloud deployment.

Run locally:
```bash
npm install
npm start
```

Docker (build + run):
```bash
docker build -t cloud-task-backend .
docker run -p 3000:3000 -e PORT=3000 cloud-task-backend
```

Endpoints:
- `GET /tasks` - list tasks
- `POST /tasks` - create task { title, completed? }
- `GET /tasks/:id` - get task
- `PUT /tasks/:id` - update task { title?, completed? }
- `DELETE /tasks/:id` - delete task

Notes:
- This implementation uses an in-memory store; for production, replace with a database.

MongoDB
--
This service can connect to MongoDB via the `MONGODB_URI` environment variable. Create a MongoDB Atlas cluster (or use AWS DocumentDB) and set `MONGODB_URI` to the connection string.

Example local run with Atlas:
```bash
export MONGODB_URI="mongodb+srv://<user>:<pass>@cluster0.example.mongodb.net/mydb?retryWrites=true&w=majority"
npm start
```

If `MONGODB_URI` is not set, the server falls back to the bundled in-memory store (good for smoke tests only).

AWS Deployment (container image -> ECR -> ECS Fargate)
--
1. Build and tag image locally:
```bash
docker build -t cloud-task-backend:latest .
```
2. Create ECR repository and push image (simplified):
```bash
aws ecr create-repository --repository-name cloud-task-backend
aws ecr get-login-password | docker login --username AWS --password-stdin <aws_account_id>.dkr.ecr.<region>.amazonaws.com
docker tag cloud-task-backend:latest <aws_account_id>.dkr.ecr.<region>.amazonaws.com/cloud-task-backend:latest
docker push <aws_account_id>.dkr.ecr.<region>.amazonaws.com/cloud-task-backend:latest
```
3. Create an ECS cluster and task definition using Fargate, set container port to `3000` and pass env vars `PORT` and `MONGODB_URI` (or use Secrets Manager for credentials).
4. Create a Service on the cluster using the task definition, and attach to an Application Load Balancer if you need HTTP exposure.

CI/CD and IAM notes:
- Use IAM roles for ECS tasks to grant access to Secrets Manager or other AWS services.
- For automated deploys, create a GitHub Actions workflow to build, push to ECR, and update the ECS service.

GitHub Actions (example)
--
This repo contains an example workflow at `.github/workflows/deploy.yml` that builds the Docker image, pushes to ECR, and deploys an updated task definition to ECS. Before using it, add these repository Secrets in GitHub:

- `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` — IAM user with permissions to push to ECR and update ECS.
- `AWS_REGION` — e.g. `us-east-1`.
- `AWS_ACCOUNT_ID` — your AWS account id.
- `ECR_REPOSITORY` — the ECR repo name (e.g. `cloud-task-backend`).
- `ECS_CLUSTER` — the ECS cluster name.
- `ECS_SERVICE` — the ECS service name to update.

The workflow uses `backend/ecs-task-def.json` as a template; it will replace the image reference with the built image tag.

Secrets Manager
--
For sensitive values like DB credentials, store them in AWS Secrets Manager and reference them from the task definition `secrets` section, or inject them as environment variables via CI using GitHub Secrets.


