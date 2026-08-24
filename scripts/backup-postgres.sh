#!/usr/bin/env sh
set -eu
mkdir -p backups
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
FILE="backups/netsera-${STAMP}.dump"

docker compose --env-file .env.deploy -f docker-compose.deploy.yml   exec -T postgres sh -lc   'pg_dump -Fc -U "$POSTGRES_USER" -d "$POSTGRES_DB"' > "$FILE"

echo "Backup complete: $FILE"
