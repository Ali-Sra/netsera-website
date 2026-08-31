# Netsera Mobile - Phase 5

Phase 5 connects the Infrastructure tab to real backend health endpoints.

## Real checks

- `GET /health/live` — API process liveness
- `GET /health/ready` — readiness including PostgreSQL
- HTTP status
- response latency measured by the mobile client
- last check time
- automatic refresh every 15 seconds
- pull-to-refresh and manual refresh

## Honest lab boundary

VMware, Hyper-V, firewall, VLAN and security lab telemetry are still marked
as DEMO / not connected. No fabricated lab values are presented as production
telemetry.

## Physical iPhone

The mobile `.env` must point to a backend address reachable from the phone,
for example:

`EXPO_PUBLIC_API_URL=http://192.168.x.x:8080`

For App Store / production deployment, use a public HTTPS API instead.
