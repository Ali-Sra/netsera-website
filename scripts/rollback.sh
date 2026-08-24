#!/usr/bin/env sh
set -eu
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <known-good-commit-or-tag>"
  exit 1
fi
TARGET="$1"
COMPOSE="docker compose --env-file .env.deploy -f docker-compose.deploy.yml"

git fetch --all --tags
git checkout "$TARGET"
$COMPOSE build backend frontend
$COMPOSE up -d backend frontend caddy
$COMPOSE ps

echo "Database migrations are NOT automatically rolled back."
