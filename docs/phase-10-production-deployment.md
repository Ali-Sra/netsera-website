# Phase 10 — Production Deployment

## Goal

Deploy Netsera to a Linux VPS with a real domain, automatic HTTPS/TLS, controlled EF Core migrations, PostgreSQL backups, health checks, and documented update/rollback procedures.

## Production architecture

```text
Internet
   |
   v
DNS A/AAAA
   |
   v
Caddy :80/:443
   |---------------------------|
   v                           v
Next.js :3000           ASP.NET Core :8080
                               |
                               v
                         PostgreSQL :5432
                         private network only
```

Phase 9 keeps Nginx for local production-like testing. Phase 10 uses Caddy at the public edge because it can obtain and renew TLS certificates automatically.

## Recommended server baseline

- Ubuntu 24.04 LTS or comparable current Linux distribution
- Docker Engine + Docker Compose plugin
- Git
- firewall allowing only SSH, TCP 80, TCP 443, and optionally UDP 443
- PostgreSQL must not be exposed publicly

## DNS

Point the production domain to the VPS public IP.

Typical records:

```text
A     @      SERVER_IPV4
A     www    SERVER_IPV4
```

Add AAAA only if IPv6 is configured correctly.

## First deployment

```bash
git clone https://github.com/Ali-Sra/netsera-website.git
cd netsera-website

cp .env.deploy.example .env.deploy
nano .env.deploy

chmod 600 .env.deploy
chmod +x scripts/*.sh

./scripts/deploy.sh
```

The deployment order is:

1. pull source
2. build backend/frontend/migration images
3. start PostgreSQL
4. run EF Core migrations
5. start backend/frontend/Caddy
6. show service status

## HTTPS

Caddy automatically requests and renews TLS certificates after:

- DNS points to the server
- ports 80 and 443 reach the VPS
- `DOMAIN` and `ACME_EMAIL` are set in `.env.deploy`

## Health verification

```bash
./scripts/healthcheck.sh
```

Manual URLs:

```text
https://YOUR_DOMAIN/
https://YOUR_DOMAIN/health/live
https://YOUR_DOMAIN/health/ready
https://YOUR_DOMAIN/admin/login
```

## Controlled database migrations

Migrations are intentionally not run implicitly on every application startup.

Run manually when needed:

```bash
docker compose --env-file .env.deploy -f docker-compose.deploy.yml run --rm migrate
```

## Backup

```bash
./scripts/backup-postgres.sh
```

Backups are written to:

```text
backups/netsera-YYYYMMDDTHHMMSSZ.dump
```

Recommended policy:

- daily backups
- at least seven daily copies
- off-server encrypted copies
- periodically test restore

## Restore

```bash
./scripts/restore-postgres.sh backups/<backup-file>.dump
```

The script requires explicit confirmation before destructive restore.

## Updates

Recommended sequence:

```bash
./scripts/backup-postgres.sh
./scripts/deploy.sh
./scripts/healthcheck.sh
```

Review destructive or irreversible migrations before deployment.

## Rollback

Application rollback:

```bash
./scripts/rollback.sh <known-good-commit-or-tag>
```

This rolls back application code/images only. Database migrations are not automatically reversed.

## Secrets

Never store production secrets in Git, frontend code, Dockerfiles, screenshots, README files, or CI logs.

For a first VPS deployment, `.env.deploy` with file mode `600` is acceptable.

## Logs

```bash
docker compose --env-file .env.deploy -f docker-compose.deploy.yml logs -f --tail=200
```

Backend:

```bash
docker compose --env-file .env.deploy -f docker-compose.deploy.yml logs -f backend
```

Caddy:

```bash
docker compose --env-file .env.deploy -f docker-compose.deploy.yml logs -f caddy
```

## Monitoring minimum

- `/health/live`
- `/health/ready`
- Docker restart status
- disk-space monitoring
- certificate status
- database backup success

For a real business deployment, add external uptime monitoring and centralized logs.

## Firewall example

After confirming SSH access:

```bash
sudo ufw allow OpenSSH
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 443/udp
sudo ufw enable
```

Do not expose PostgreSQL 5432.

## Production acceptance checklist

- DNS resolves to the VPS
- HTTPS works without a browser warning
- HTTP redirects to HTTPS
- PostgreSQL is not publicly exposed
- `/health/live` succeeds
- `/health/ready` succeeds
- admin login works
- contact form persists a message
- project/service admin changes work
- audit logs receive admin actions
- backup creation succeeds
- restore procedure is tested safely
- CI is green
- `.env.deploy` is not tracked by Git
- update procedure works
- a rollback target/tag exists

## Go-live boundary

After Phase 10 files build successfully and the Release check workflow is green, the repository is deployment-ready.

Actual public go-live still requires a VPS/public host and a domain pointing to it.
