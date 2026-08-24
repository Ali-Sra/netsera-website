#!/usr/bin/env sh
set -eu
COMPOSE="docker compose --env-file .env.deploy -f docker-compose.deploy.yml"

echo "==> Pull latest code"
git pull --ff-only

echo "==> Build application images"
$COMPOSE build backend frontend migrate

echo "==> Start PostgreSQL"
$COMPOSE up -d postgres

echo "==> Run EF Core migrations"
$COMPOSE run --rm migrate

echo "==> Start application and HTTPS reverse proxy"
$COMPOSE up -d backend frontend caddy

echo "==> Current status"
$COMPOSE ps
