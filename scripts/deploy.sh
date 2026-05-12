#!/bin/bash
set -euo pipefail

ENV=${1:-prod}

# Write .env file fresh on every deploy
cat > .env <<EOF
TELEGRAM_TOKEN=${TELEGRAM_TOKEN}
DATABASE_URL=${DATABASE_URL}
ENV=${ENV}
EOF

echo "✅ .env written"

#ECR_REGISTRY="<your-account-id>.dkr.ecr.<region>.amazonaws.com"
ECR_REGISTRY=${ECR_REGISTRY}
IMAGE="$ECR_REGISTRY/peredachka:${IMAGE_TAG:-latest}"
COMPOSE_FILE="docker-compose.yml"

echo "▶ Deploying [$ENV] — image: $IMAGE"

# Pull latest image from ECR
aws ecr get-login-password --region <region> | \
  docker login --username AWS --password-stdin $ECR_REGISTRY

docker pull $IMAGE

# UAT uses override file
if [ "$ENV" = "uat" ]; then
  COMPOSE_FILE="-f docker-compose.yml -f docker-compose.uat.yml"
fi

# Zero-downtime swap
IMAGE_TAG=${IMAGE_TAG} docker compose $COMPOSE_FILE up -d --no-build

# Health check
bash scripts/health_check.sh || {
  echo "❌ Health check failed — rolling back"
  docker compose $COMPOSE_FILE down
  exit 1
}

# Cleanup old images
docker image prune -f

echo "✅ Deploy complete [$ENV]"
