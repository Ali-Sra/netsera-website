# Netsera Mobile — Phase 6

Phase 6 establishes the production/build foundation without pretending the app
is already ready for App Store or Google Play submission.

## Added

- EAS build configuration
- iOS bundle identifier: `de.netsera.mobile`
- Android package: `de.netsera.mobile`
- production environment example
- normalized API base URL
- TypeScript quality script
- cache-clear start script

## Current local development

A physical phone can continue using a LAN API URL in `.env`, for example:

`EXPO_PUBLIC_API_URL=http://192.168.x.x:8080`

Do not commit a machine-specific `.env`.

## Before public store release

The production mobile app must use a public HTTPS backend, for example:

`EXPO_PUBLIC_API_URL=https://api.netsera.de`

Still required before store submission:

1. Real production HTTPS API/domain
2. Production PostgreSQL/secrets
3. App icon and splash assets
4. Privacy policy URL
5. Apple Developer account
6. Google Play Console account
7. EAS project initialization/login
8. Physical-device release testing
9. Store screenshots and listing text
10. Privacy/data-collection declarations
