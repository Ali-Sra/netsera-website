# Netsera Mobile — Phase 2 Foundation

This folder contains the Expo/React Native mobile application for Netsera.

## Current state

- Expo SDK 54
- React Native + TypeScript
- Expo Router
- Five-tab Netsera navigation:
  - Home
  - Services
  - Projects
  - Infrastructure
  - Contact
- Shared theme tokens
- Typed API client
- Public API endpoint definitions
- Local environment configuration
- Reusable screen container
- Original Expo template backed up in `_template_backup/`

## API configuration

The default `.env` uses:

`EXPO_PUBLIC_API_URL=http://localhost:8080`

That works for web when the backend is local.

For a physical iPhone, `localhost` points to the phone itself. Set `EXPO_PUBLIC_API_URL`
to the Windows PC LAN address, for example:

`EXPO_PUBLIC_API_URL=http://192.168.2.50:8080`

The backend must also listen on an address reachable from the phone and Windows Firewall
must allow the development port.

## Next phase

Phase 3 will replace the placeholder screens with the professional Netsera mobile UI and
reusable design-system components.
