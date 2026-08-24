#!/usr/bin/env sh
set -eu
[ -f .env.deploy ] || { echo ".env.deploy not found"; exit 1; }
DOMAIN="$(grep '^DOMAIN=' .env.deploy | cut -d= -f2-)"

curl --fail --silent --show-error "https://${DOMAIN}/health/live"
echo
curl --fail --silent --show-error "https://${DOMAIN}/health/ready"
echo
echo "Health checks passed."
