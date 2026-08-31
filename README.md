# Netsera

**Infrastructure / Security / Operations**

Netsera ist ein praxisorientiertes Full-Stack-Projekt, das
Webentwicklung, Backend-Architektur, Datenhaltung, Authentifizierung,
Deployment und mobile Clients in einer gemeinsamen technischen Plattform
verbindet.

Im Mittelpunkt steht nicht nur die Benutzeroberfläche, sondern das
Zusammenspiel der einzelnen Systemkomponenten: Ein Next.js-Frontend und
eine React-Native-/Expo-App greifen über eine ASP.NET-Core-API auf eine
zentrale PostgreSQL-Datenbank zu. Ergänzt wird die Anwendung durch einen
geschützten Administrationsbereich, operative Health Checks,
Security-Middleware und containerisierte Entwicklungs- und
Deployment-Konfigurationen.

> **Produktiv:** Das Web-Frontend ist unter `netsera.de` erreichbar.
> Frontend, API und Datenbank werden als getrennte Komponenten
> betrieben.

------------------------------------------------------------------------

## Überblick

Netsera dient als technische Plattform und persönliches
Engineering-Projekt mit Schwerpunkt auf den Bereichen **Infrastructure,
Security und Operations**.

Die Anwendung umfasst derzeit unter anderem:

-   eine responsive Webanwendung auf Basis von Next.js und TypeScript,
-   eine REST API mit ASP.NET Core 8,
-   PostgreSQL als zentrale relationale Datenbank,
-   Entity Framework Core inklusive Migrationen,
-   einen geschützten Administrationsbereich,
-   serverseitige Cookie-Authentifizierung,
-   Verwaltung und Bereitstellung von Projekten und Services,
-   ein Kontaktformular mit persistenter Speicherung,
-   Audit Logging für administrative Vorgänge,
-   Rate Limiting und Security Headers,
-   Liveness- und Readiness-Health-Checks,
-   Docker-/Docker-Compose-Konfigurationen,
-   eine React-Native-/Expo-App mit gemeinsamer Backend-API.

Das Projekt wird kontinuierlich erweitert. Dabei liegt der Fokus darauf,
technische Konzepte nicht isoliert zu demonstrieren, sondern sie in
einer nachvollziehbaren Gesamtarchitektur miteinander zu verbinden.

------------------------------------------------------------------------

## Architektur

Die Anwendung folgt einer klaren Trennung zwischen Clients, API und
Persistenzschicht.

``` mermaid
flowchart TD
    U[Browser / Benutzer] -->|HTTPS| WEB[Next.js Frontend]
    M[React Native / Expo App] -->|REST / HTTPS| API[ASP.NET Core API]
    WEB -->|REST / HTTPS| API
    API -->|EF Core / Npgsql| DB[(PostgreSQL)]
    ADMIN[Administrator] -->|HTTPS| WEB
    WEB -->|Cookie-basierte Authentifizierung| API
```

Für den produktiven Betrieb sind Frontend und Backend voneinander
getrennt. Das Web-Frontend wird über Vercel bereitgestellt, während die
ASP.NET-Core-API und PostgreSQL über Render betrieben werden.

Diese Trennung ermöglicht es, Web- und Mobile-Clients über dieselbe API
und dieselbe zentrale Datenbasis zu versorgen.

------------------------------------------------------------------------

## Technologie-Stack

  -----------------------------------------------------------------------
  Bereich                             Technologien
  ----------------------------------- -----------------------------------
  Frontend                            Next.js, React, TypeScript,
                                      Tailwind CSS

  Backend                             ASP.NET Core 8, C#, REST API

  Persistenz                          PostgreSQL, Entity Framework Core,
                                      Npgsql

  Mobile                              React Native, Expo, TypeScript

  Authentifizierung                   ASP.NET Core Cookie Authentication

  Security                            CORS, Rate Limiting, Security
                                      Headers, HttpOnly/Secure Cookies,
                                      Audit Logging

  Infrastruktur                       Docker, Docker Compose, Nginx

  Deployment                          Vercel, Render

  Automation                          GitHub Actions
  -----------------------------------------------------------------------

------------------------------------------------------------------------

## Repository-Struktur

``` text
netsera-website/
├── .github/          GitHub-Workflows und Repository-Automatisierung
├── backend/          ASP.NET Core API und Persistenzschicht
├── docs/             Architektur- und Projektdokumentation
├── frontend/         Next.js Webanwendung
├── infrastructure/   Infrastruktur-, Proxy- und Deployment-Konfiguration
├── mobile/           React Native / Expo App
├── scripts/          Entwicklungs- und Betriebsskripte
├── docker-compose.yml
└── README.md
```

Die Trennung der Bereiche soll Verantwortlichkeiten klar halten und die
Anwendung sowohl lokal als auch in einer verteilten Deployment-Umgebung
nachvollziehbar machen.

------------------------------------------------------------------------

## Frontend

Das Web-Frontend basiert auf **Next.js, React und TypeScript**.

Es bildet die öffentliche Netsera-Oberfläche und stellt unter anderem
Inhalte aus den Bereichen Services und Projekte dar. Die Kommunikation
mit dem Backend erfolgt über die REST API.

Zu den umgesetzten Bereichen gehören:

-   öffentliche Startseite,
-   Services,
-   Projekte und Projektdetails,
-   Kontaktfunktion,
-   Administrationsoberfläche,
-   responsive Darstellung für unterschiedliche Bildschirmgrößen.

Die API-Basisadresse wird über Environment-Konfigurationen
bereitgestellt, sodass lokale und produktive Umgebungen getrennt
betrieben werden können.

------------------------------------------------------------------------

## Backend & API

Das Backend basiert auf **ASP.NET Core 8** und stellt die zentrale REST
API der Plattform bereit.

Zu den Aufgaben der API gehören:

-   Bereitstellung von Projekten und Services,
-   Verarbeitung von Kontaktanfragen,
-   administrative Funktionen,
-   Authentifizierung und Autorisierung,
-   Datenbankzugriff über Entity Framework Core,
-   Audit Logging,
-   Health Checks,
-   Rate Limiting,
-   zentrale Security- und Exception-Middleware.

Die Anwendung verwendet Dependency Injection und trennt Domänen-,
Application-, Infrastructure- und API-Verantwortlichkeiten in
eigenständige Projektbereiche.

------------------------------------------------------------------------

## Datenbank

Als relationale Datenbank wird **PostgreSQL** eingesetzt.

Der Datenzugriff erfolgt über **Entity Framework Core** und den
PostgreSQL-Provider Npgsql. Änderungen am Datenbankschema werden über
EF-Core-Migrationen versioniert.

Beim Start der API werden ausstehende Migrationen geprüft und
angewendet, bevor auf die benötigten Tabellen zugegriffen wird.

Dadurch bleiben Anwendungscode und Datenbankschema über die
Deployment-Umgebungen hinweg synchron.

Produktive Zugangsdaten und Connection Strings gehören nicht in das
Repository und werden ausschließlich über Environment-Konfigurationen
bereitgestellt.

------------------------------------------------------------------------

## Administration & Authentifizierung

Netsera verfügt über einen nichtöffentlichen Administrationsbereich.

Die Authentifizierung erfolgt serverseitig über **ASP.NET Core Cookie
Authentication**. Nach erfolgreicher Anmeldung wird eine geschützte
Session über ein Authentifizierungs-Cookie geführt.

Die Konfiguration berücksichtigt unter anderem:

-   `HttpOnly` zum Schutz vor direktem JavaScript-Zugriff,
-   `Secure` für die Übertragung über HTTPS,
-   `SameSite`-Konfiguration für die produktive
    Frontend-/API-Kommunikation,
-   geschützte administrative Endpunkte,
-   definierte Antworten für nicht authentifizierte bzw. nicht
    autorisierte Zugriffe,
-   Audit Logging administrativer Vorgänge.

Initiale Administrator-Konfigurationen werden über Environment-Variablen
bereitgestellt. Reale Zugangsdaten werden nicht im Repository
dokumentiert.

------------------------------------------------------------------------

## Security

Security wird als Bestandteil der Anwendungsarchitektur behandelt und
nicht ausschließlich als nachträgliche Ergänzung.

Aktuell berücksichtigt die Backend-Konfiguration unter anderem:

-   Authentifizierung und Autorisierung,
-   HttpOnly- und Secure-Cookies,
-   CORS mit definierten erlaubten Origins,
-   Credential-Unterstützung für authentifizierte Requests,
-   Rate Limiting für sensible Endpunkte,
-   Security Headers,
-   Audit Logging,
-   zentrale Fehlerbehandlung,
-   getrennte Environment-Konfigurationen,
-   Secret-Konfiguration außerhalb des Repositorys.

Die Sicherheitskonfiguration wird mit der Weiterentwicklung der
Plattform fortlaufend überprüft und erweitert.

------------------------------------------------------------------------

## Health & Operations

Für den operativen Zustand der API stehen Health-Check-Endpunkte zur
Verfügung.

``` text
/health
/health/live
/health/ready
```

`/health/live` dient als einfacher Liveness-Check für den laufenden
API-Prozess.

`/health/ready` berücksichtigt zusätzlich die Betriebsbereitschaft
abhängiger Komponenten, insbesondere der Datenbank.

Die Trennung zwischen Liveness und Readiness ist insbesondere für
Container- und Hosting-Umgebungen sinnvoll: Ein laufender Prozess ist
nicht automatisch bereit, produktive Requests zu verarbeiten.

------------------------------------------------------------------------

## Mobile App

Neben der Webanwendung enthält das Repository eine mobile Anwendung auf
Basis von **React Native und Expo**.

Die Mobile App verwendet dieselbe REST API wie das Web-Frontend. Dadurch
bleiben Datenzugriff und zentrale Geschäftslogik im Backend gebündelt.

Aktuell sind unter anderem folgende Bereiche angebunden:

-   Services,
-   Projekte,
-   Projektdetails,
-   Kontaktfunktion,
-   API- und Health-Kommunikation.

Die gemeinsame API verhindert, dass dieselbe Backend-Logik separat für
Web und Mobile implementiert werden muss.

------------------------------------------------------------------------

## Deployment

### Lokale Entwicklung

Für die lokale Entwicklung stehen Docker- und
Docker-Compose-Konfigurationen sowie getrennte Frontend-, Backend- und
Mobile-Projekte zur Verfügung.

Vereinfacht ergibt sich lokal folgende Struktur:

``` text
Next.js / Expo
      |
      v
ASP.NET Core API
      |
      v
PostgreSQL
```

### Produktion

Die produktive Architektur ist aktuell auf mehrere Dienste verteilt:

``` mermaid
flowchart LR
    USER[Browser] -->|HTTPS| VERCEL[Vercel / Next.js]
    VERCEL -->|REST / HTTPS| RENDERAPI[Render / ASP.NET Core API]
    MOBILE[Mobile Client] -->|REST / HTTPS| RENDERAPI
    RENDERAPI --> DB[(Render / PostgreSQL)]
```

Diese Architektur trennt Präsentation, API und Persistenz und erlaubt
den Clients, dieselbe Backend-Schnittstelle zu verwenden.

------------------------------------------------------------------------

## Lokale Entwicklung

### Voraussetzungen

Je nach verwendetem Teilprojekt werden benötigt:

-   Node.js / npm
-   .NET 8 SDK
-   Docker und Docker Compose
-   PostgreSQL bzw. die bereitgestellte Docker-Umgebung
-   Expo CLI / Expo Go für die mobile Entwicklung

### Repository klonen

``` bash
git clone <repository-url>
cd netsera-website
```

### Frontend

``` bash
cd frontend
npm install
npm run dev
```

### Backend

``` bash
cd backend/src/Netsera.Api
dotnet restore
dotnet run
```

### Mobile App

``` bash
cd mobile
npm install
npx expo start
```

Für Tests auf einem physischen Mobilgerät muss die konfigurierte
API-Adresse vom Gerät erreichbar sein. In lokalen Netzwerken kann dafür
beispielsweise die LAN-Adresse des Entwicklungsrechners verwendet
werden.

### Docker

Die vorhandenen Compose-Dateien bilden die Grundlage für
containerisierte lokale bzw. deploymentnahe Umgebungen.

``` bash
docker compose up --build
```

Die konkreten Environment-Werte müssen vor dem Start entsprechend der
jeweiligen Umgebung konfiguriert werden.

------------------------------------------------------------------------

## Konfiguration

Konfigurationswerte werden über Environment-Variablen bzw. die
vorhandenen `.env.example`-Dateien dokumentiert.

Typische Konfigurationsbereiche sind:

``` text
ConnectionStrings__DefaultConnection=<POSTGRES_CONNECTION_STRING>
Cors__AllowedOrigins__0=<FRONTEND_ORIGIN>
AdminBootstrap__Email=<ADMIN_EMAIL>
AdminBootstrap__Password=<ADMIN_PASSWORD>
NEXT_PUBLIC_API_BASE_URL=<API_BASE_URL>
```

Die tatsächlichen Namen und Beispielwerte sollten immer mit den im
Repository vorhandenen Environment-Beispieldateien abgeglichen werden.

**Produktive Secrets, Passwörter und Datenbankzugänge dürfen nicht
committed werden.**

------------------------------------------------------------------------

## CI/CD und Repository-Automatisierung

Das Repository enthält GitHub-Actions-Konfigurationen unter
`.github/workflows/`.

Die Workflows dienen der automatisierten Validierung von Änderungen und
unterstützen einen reproduzierbaren Entwicklungsprozess. Die konkrete
Pipeline sollte stets gemeinsam mit den Workflow-Dateien betrachtet
werden, da Build-, Test- und Deployment-Schritte im Laufe der
Projektentwicklung angepasst werden können.

------------------------------------------------------------------------

## Projektstatus

Netsera befindet sich in aktiver Entwicklung.

### Implementiert

-   Next.js Web-Frontend
-   ASP.NET Core REST API
-   PostgreSQL-Persistenz
-   EF-Core-Migrationen
-   Kontaktfunktion
-   Projekte und Services
-   Administrationsbereich
-   Cookie-basierte Admin-Authentifizierung
-   Audit Logging
-   Rate Limiting
-   Health Checks
-   Docker-/Compose-Konfiguration
-   produktive Web-/API-/Datenbank-Bereitstellung
-   React-Native-/Expo-Mobile-App mit API-Integration

### In Weiterentwicklung

-   Ausbau des Security Lab
-   weitere Infrastruktur-Visualisierungen
-   Ausbau der Mobile App
-   Verbesserung von Operations und Observability

### Perspektive

Weitere Themen aus den Bereichen Identity & Access Management,
Monitoring, Netzwerksegmentierung, Cloud und Security sollen
schrittweise in die Plattform integriert werden, sofern sie technisch
sinnvoll in die bestehende Architektur passen.

------------------------------------------------------------------------

## Engineering-Ziele

Netsera ist bewusst als praxisnahes Engineering-Projekt aufgebaut.

Das Ziel besteht darin, nicht nur einzelne Frameworks zu verwenden,
sondern die Übergänge zwischen verschiedenen technischen Disziplinen
nachvollziehbar umzusetzen:

**Frontend → API → Authentifizierung → Datenbank → Container →
Deployment → Operations → Mobile**

Damit dient das Projekt gleichzeitig als Entwicklungsumgebung,
technische Dokumentation und Portfolio für Themen aus
Softwareentwicklung und IT-Infrastruktur.

Besonderer Wert liegt auf nachvollziehbarer Architektur,
reproduzierbarer Konfiguration und einer klaren Trennung zwischen
öffentlichem Code und produktiven Secrets.

------------------------------------------------------------------------

## Roadmap

Die Weiterentwicklung orientiert sich an realistischen Infrastruktur-
und Operations-Szenarien. Dazu gehören insbesondere:

-   Ausbau des Netsera Security Lab,
-   Netzwerk- und Infrastruktur-Simulationen,
-   Monitoring und Observability,
-   Identity- und Access-Management-Szenarien,
-   weitere Security- und Operations-Funktionen,
-   Ausbau der Mobile-Integration.

Die Roadmap ist bewusst technisch ausgerichtet. Neue Funktionen sollen
nicht nur visuell ergänzt, sondern in die vorhandene Architektur
integriert werden.

------------------------------------------------------------------------

## Hinweis

Netsera ist ein persönliches, praxisorientiertes Engineering- und
Portfolio-Projekt. Es dient dazu, Full-Stack-Entwicklung,
Systemarchitektur, Security, Deployment und Infrastrukturkonzepte in
einer zusammenhängenden Anwendung praktisch umzusetzen.

------------------------------------------------------------------------

**Netsera --- Infrastructure / Security / Operations**
