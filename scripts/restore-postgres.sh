#!/usr/bin/env sh
set -eu
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 backups/netsera-YYYYMMDDTHHMMSSZ.dump"
  exit 1
fi
FILE="$1"
[ -f "$FILE" ] || { echo "Backup not found: $FILE"; exit 1; }

echo "WARNING: restore will replace data."
printf "Type RESTORE to continue: "
read answer
[ "$answer" = "RESTORE" ] || { echo "Cancelled."; exit 1; }

docker compose --env-file .env.deploy -f docker-compose.deploy.yml   exec -T postgres sh -lc   'pg_restore --clean --if-exists --no-owner -U "$POSTGRES_USER" -d "$POSTGRES_DB"' < "$FILE"

echo "Restore complete."
