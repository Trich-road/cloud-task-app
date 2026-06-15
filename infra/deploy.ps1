param(
    [string]$AwsRegion = "us-east-1",
    [string]$AwsAccountId = "<AWS_ACCOUNT_ID>",
    [string]$EcrRepo = "<REPO>",
    [string]$ImageTag = "latest",
    [string]$MongoDbSecretName = "<SECRET_NAME>",
    [switch]$UseSecretArn
)

$ecrImage = "$AwsAccountId.dkr.ecr.$AwsRegion.amazonaws.com/$EcrRepo:$ImageTag"

Write-Host "Deploying with image: $ecrImage"
Write-Host "Using AWS region: $AwsRegion"
Write-Host "Using Secrets Manager: $MongoDbSecretName"

Set-Location -Path "$PSScriptRoot"

terraform init

if ($UseSecretArn) {
    $secretValue = "arn:aws:secretsmanager:$AwsRegion:$AwsAccountId:secret:$MongoDbSecretName"
    terraform plan `
      -var="aws_region=$AwsRegion" `
      -var="image=$ecrImage" `
      -var="mongodb_secret_arn=$secretValue" `
      -out="plan.tfplan"
} else {
    terraform plan `
      -var="aws_region=$AwsRegion" `
      -var="image=$ecrImage" `
      -var="mongodb_secret_name=$MongoDbSecretName" `
      -out="plan.tfplan"
}

terraform apply -auto-approve ".\plan.tfplan"
