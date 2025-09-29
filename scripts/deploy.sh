#!/bin/bash
set -e

ENVIRONMENT=${1:-dev}          # dev | test | prod
PROJECT_NAME=${2:-twin}

echo "🚀 Deploying ${PROJECT_NAME} to ${ENVIRONMENT}..."

# 1. Build Lambda package
cd "$(dirname "$0")/.."        # project root
echo "📦 Building Lambda package..."
(cd backend && uv run deploy.py)

# 2. Terraform workspace & apply
cd terraform
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION=${DEFAULT_AWS_REGION:-us-east-2}
terraform init -input=false \
  -backend-config="bucket=twin-terraform-state-${AWS_ACCOUNT_ID}" \
  -backend-config="key=${ENVIRONMENT}/terraform.tfstate" \
  -backend-config="region=${AWS_REGION}" \
  -backend-config="dynamodb_table=twin-terraform-locks" \
  -backend-config="encrypt=true"

if ! terraform workspace list | grep -q "$ENVIRONMENT"; then
  terraform workspace new "$ENVIRONMENT"
else
  terraform workspace select "$ENVIRONMENT"
fi

# Use prod.tfvars for production environment
if [ "$ENVIRONMENT" = "prod" ]; then
  TF_APPLY_CMD=(terraform apply -var-file=prod.tfvars -var="project_name=$PROJECT_NAME" -var="environment=$ENVIRONMENT" -auto-approve)
else
  TF_APPLY_CMD=(terraform apply -var="project_name=$PROJECT_NAME" -var="environment=$ENVIRONMENT" -auto-approve)
fi

echo "📋 Planning Terraform changes..."
terraform plan -var="project_name=$PROJECT_NAME" -var="environment=$ENVIRONMENT"

echo "🎯 Applying Terraform..."
"${TF_APPLY_CMD[@]}"

# Check if outputs exist before trying to get them
if terraform output api_gateway_url >/dev/null 2>&1; then
  API_URL=$(terraform output -raw api_gateway_url)
  FRONTEND_BUCKET=$(terraform output -raw s3_frontend_bucket)
  CUSTOM_URL=$(terraform output -raw custom_domain_url 2>/dev/null || true)
else
  echo "❌ Terraform outputs not found. This usually means no resources were created."
  echo "Please check your Terraform configuration and try again."
  exit 1
fi

# 3. Build + deploy frontend
cd ../frontend

# Create production environment file with API URL
echo "📝 Setting API URL for production..."
echo "NEXT_PUBLIC_API_URL=$API_URL" > .env.production

npm install
npm run build

echo "🚀 Deploying frontend to S3..."
if aws s3 sync ./out "s3://$FRONTEND_BUCKET/" --delete; then
  echo "✅ Frontend deployed successfully"
else
  echo "❌ Failed to deploy frontend to S3"
  exit 1
fi
cd ..

# 4. Final messages
echo -e "\n✅ Deployment complete!"
echo "🌐 CloudFront URL : $(terraform -chdir=terraform output -raw cloudfront_url)"
if [ -n "$CUSTOM_URL" ]; then
  echo "🔗 Custom domain  : $CUSTOM_URL"
fi
echo "📡 API Gateway    : $API_URL"