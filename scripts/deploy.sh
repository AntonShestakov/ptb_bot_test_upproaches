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