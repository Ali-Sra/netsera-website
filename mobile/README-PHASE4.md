# Netsera Mobile — Phase 4 API Integration

Phase 4 connects the public mobile screens to the existing ASP.NET Core API.

Real endpoints used:

- GET /api/content/services
- GET /api/content/projects
- POST /api/contact

The backend already exposes published Services and Projects through the public content controller,
and the contact endpoint returns HTTP 201 for a successfully created message.

## Important: physical iPhone

When Expo Go runs on a physical iPhone, `localhost` means the iPhone itself.

The `mobile/.env` value must therefore point to an API address reachable by the phone, for example:

EXPO_PUBLIC_API_URL=http://192.168.2.50:8080

Replace the IP above with the actual LAN IPv4 address of the Windows PC.

The ASP.NET backend must also listen on a reachable interface and Windows Firewall must permit the port.

After changing `.env`, restart Expo/Metro.

## Phase 4 features

- real Services API data
- real Projects API data
- pull-to-refresh
- loading state
- error state
- empty state
- project detail route
- project/GitHub external links
- real Contact POST
- basic client-side validation
- HTTP 429 handling
