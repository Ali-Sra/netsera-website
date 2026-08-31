$ErrorActionPreference = "Stop"

function Write-Step($text) {
    Write-Host ""
    Write-Host "==> $text" -ForegroundColor Cyan
}

function Write-Ok($text) {
    Write-Host "    $text" -ForegroundColor Green
}

# ------------------------------------------------------------
# Netsera Mobile - Phase 2 Continue
# Expected: run from netsera-website repository root.
# This script DOES NOT recreate the Expo project.
# It configures the existing mobile/ Expo Router project.
# ------------------------------------------------------------

Write-Step "Checking repository"

if (-not (Test-Path ".git")) {
    throw "Run this script from the netsera-website repository root (the folder containing .git)."
}

if (-not (Test-Path "mobile\package.json")) {
    throw "mobile/package.json was not found. Create the Expo mobile project first."
}

$packageJson = Get-Content "mobile\package.json" -Raw
if ($packageJson -notmatch '"expo"') {
    throw "mobile/package.json does not look like an Expo project."
}

if (-not (Test-Path "mobile\app")) {
    throw "mobile/app was not found. This script expects an Expo Router project."
}

Write-Ok "Existing Expo mobile project found."

Write-Step "Creating Netsera source structure"

$dirs = @(
    "mobile\src\api",
    "mobile\src\components",
    "mobile\src\config",
    "mobile\src\theme",
    "mobile\src\types",
    "mobile\src\utils"
)

foreach ($dir in $dirs) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
}

# Backup the original Expo app folder once
$backup = "mobile\_template_backup"
if (-not (Test-Path $backup)) {
    New-Item -ItemType Directory -Force -Path $backup | Out-Null
    Copy-Item "mobile\app\*" $backup -Recurse -Force
    Write-Ok "Original Expo template backed up to mobile/_template_backup/"
}

Write-Step "Writing environment configuration"

@'
# Netsera Mobile
# Web/local development:
EXPO_PUBLIC_API_URL=http://localhost:8080

# IMPORTANT for a physical iPhone:
# localhost points to the iPhone itself.
# Later replace the value above with your PC LAN IP, for example:
# EXPO_PUBLIC_API_URL=http://192.168.2.50:8080
'@ | Set-Content "mobile\.env.example" -Encoding UTF8

if (-not (Test-Path "mobile\.env")) {
@'
EXPO_PUBLIC_API_URL=http://localhost:8080
'@ | Set-Content "mobile\.env" -Encoding UTF8
    Write-Ok "Created mobile/.env"
} else {
    Write-Ok "mobile/.env already exists - kept unchanged."
}

# Make sure local env is ignored
$gitignore = "mobile\.gitignore"
if (-not (Test-Path $gitignore)) {
    New-Item -ItemType File -Force -Path $gitignore | Out-Null
}

$ignoreText = Get-Content $gitignore -Raw -ErrorAction SilentlyContinue
if ($ignoreText -notmatch "(?m)^\.env$") {
    Add-Content $gitignore "`n# Local environment`n.env"
}

Write-Step "Writing theme and configuration"

@'
export const colors = {
  background: '#07111F',
  surface: '#0D1B2A',
  surfaceElevated: '#12243A',
  border: '#20344B',
  text: '#F5F8FC',
  textMuted: '#93A4B8',
  primary: '#38BDF8',
  primaryStrong: '#0EA5E9',
  success: '#22C55E',
  warning: '#F59E0B',
  danger: '#EF4444',
  white: '#FFFFFF',
  black: '#000000',
} as const;
'@ | Set-Content "mobile\src\theme\colors.ts" -Encoding UTF8

@'
export const spacing = {
  xs: 4,
  sm: 8,
  md: 16,
  lg: 24,
  xl: 32,
  xxl: 48,
} as const;

export const radius = {
  sm: 8,
  md: 14,
  lg: 20,
  pill: 999,
} as const;
'@ | Set-Content "mobile\src\theme\layout.ts" -Encoding UTF8

@'
export { colors } from './colors';
export { radius, spacing } from './layout';
'@ | Set-Content "mobile\src\theme\index.ts" -Encoding UTF8

@'
const rawApiUrl = process.env.EXPO_PUBLIC_API_URL?.trim();

export const appConfig = {
  apiBaseUrl: rawApiUrl || 'http://localhost:8080',
  requestTimeoutMs: 10000,
} as const;
'@ | Set-Content "mobile\src\config\app.ts" -Encoding UTF8

Write-Step "Writing API types and client"

@'
export type Project = {
  id: number;
  title: string;
  slug: string;
  shortDescription?: string | null;
  description?: string | null;
  imageUrl?: string | null;
  projectUrl?: string | null;
  githubUrl?: string | null;
  displayOrder: number;
};

export type Service = {
  id: number;
  title: string;
  slug: string;
  description?: string | null;
  icon?: string | null;
  displayOrder: number;
};

export type ContactRequest = {
  name: string;
  email: string;
  subject?: string;
  message: string;
};
'@ | Set-Content "mobile\src\types\api.ts" -Encoding UTF8

@'
import { appConfig } from '../config/app';

export class ApiError extends Error {
  status?: number;

  constructor(message: string, status?: number) {
    super(message);
    this.name = 'ApiError';
    this.status = status;
  }
}

type RequestOptions = RequestInit & {
  timeoutMs?: number;
};

export async function apiFetch<T>(
  path: string,
  options: RequestOptions = {},
): Promise<T> {
  const controller = new AbortController();
  const timeoutMs = options.timeoutMs ?? appConfig.requestTimeoutMs;

  const timeout = setTimeout(() => controller.abort(), timeoutMs);

  try {
    const response = await fetch(`${appConfig.apiBaseUrl}${path}`, {
      ...options,
      headers: {
        Accept: 'application/json',
        'Content-Type': 'application/json',
        ...options.headers,
      },
      signal: controller.signal,
    });

    if (!response.ok) {
      let message = `Request failed with status ${response.status}`;

      try {
        const body = await response.json();
        if (typeof body?.message === 'string') {
          message = body.message;
        } else if (typeof body?.title === 'string') {
          message = body.title;
        }
      } catch {
        // Ignore invalid/non-JSON error bodies.
      }

      throw new ApiError(message, response.status);
    }

    if (response.status === 204) {
      return undefined as T;
    }

    return (await response.json()) as T;
  } catch (error) {
    if (error instanceof ApiError) {
      throw error;
    }

    if (error instanceof Error && error.name === 'AbortError') {
      throw new ApiError('The request timed out.');
    }

    throw new ApiError(
      error instanceof Error ? error.message : 'Unknown network error',
    );
  } finally {
    clearTimeout(timeout);
  }
}
'@ | Set-Content "mobile\src\api\client.ts" -Encoding UTF8

@'
import { apiFetch } from './client';
import type { ContactRequest, Project, Service } from '../types/api';

export const publicApi = {
  getProjects: () => apiFetch<Project[]>('/api/content/projects'),
  getServices: () => apiFetch<Service[]>('/api/content/services'),
  sendContact: (payload: ContactRequest) =>
    apiFetch<void>('/api/contact', {
      method: 'POST',
      body: JSON.stringify(payload),
    }),
  getLiveHealth: () => apiFetch<unknown>('/health/live'),
  getReadyHealth: () => apiFetch<unknown>('/health/ready'),
};
'@ | Set-Content "mobile\src\api\publicApi.ts" -Encoding UTF8

@'
export { ApiError, apiFetch } from './client';
export { publicApi } from './publicApi';
'@ | Set-Content "mobile\src\api\index.ts" -Encoding UTF8

Write-Step "Writing reusable UI components"

@'
import type { PropsWithChildren } from 'react';
import { SafeAreaView, StyleSheet, View, type ViewStyle } from 'react-native';
import { colors } from '../theme';

type Props = PropsWithChildren<{
  style?: ViewStyle;
}>;

export function ScreenContainer({ children, style }: Props) {
  return (
    <SafeAreaView style={styles.safeArea}>
      <View style={[styles.container, style]}>{children}</View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: colors.background,
  },
  container: {
    flex: 1,
    backgroundColor: colors.background,
  },
});
'@ | Set-Content "mobile\src\components\ScreenContainer.tsx" -Encoding UTF8

@'
import { StyleSheet, Text, View } from 'react-native';
import { colors, radius, spacing } from '../theme';

type Props = {
  title: string;
  description: string;
  eyebrow?: string;
};

export function PlaceholderScreen({ title, description, eyebrow }: Props) {
  return (
    <View style={styles.container}>
      {eyebrow ? <Text style={styles.eyebrow}>{eyebrow}</Text> : null}
      <Text style={styles.title}>{title}</Text>
      <Text style={styles.description}>{description}</Text>

      <View style={styles.card}>
        <View style={styles.dot} />
        <Text style={styles.cardText}>Netsera mobile foundation is active.</Text>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    paddingHorizontal: spacing.lg,
    paddingTop: spacing.xl,
    backgroundColor: colors.background,
  },
  eyebrow: {
    color: colors.primary,
    fontSize: 12,
    fontWeight: '700',
    letterSpacing: 1.6,
    marginBottom: spacing.sm,
  },
  title: {
    color: colors.text,
    fontSize: 32,
    lineHeight: 38,
    fontWeight: '800',
  },
  description: {
    color: colors.textMuted,
    fontSize: 16,
    lineHeight: 24,
    marginTop: spacing.md,
  },
  card: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: spacing.sm,
    marginTop: spacing.xl,
    padding: spacing.md,
    borderRadius: radius.md,
    borderWidth: 1,
    borderColor: colors.border,
    backgroundColor: colors.surface,
  },
  dot: {
    width: 9,
    height: 9,
    borderRadius: 999,
    backgroundColor: colors.success,
  },
  cardText: {
    color: colors.text,
    fontSize: 14,
    fontWeight: '600',
  },
});
'@ | Set-Content "mobile\src\components\PlaceholderScreen.tsx" -Encoding UTF8

Write-Step "Replacing Expo demo tabs with Netsera navigation"

# Remove demo route files but keep the app folder.
if (Test-Path "mobile\app\(tabs)") {
    Remove-Item "mobile\app\(tabs)" -Recurse -Force
}

New-Item -ItemType Directory -Force -Path "mobile\app\(tabs)" | Out-Null

@'
import FontAwesome from '@expo/vector-icons/FontAwesome';
import { Tabs } from 'expo-router';
import { colors } from '../../src/theme';

type IconName = React.ComponentProps<typeof FontAwesome>['name'];

function TabIcon({
  name,
  color,
}: {
  name: IconName;
  color: string;
}) {
  return <FontAwesome size={21} name={name} color={color} />;
}

export default function TabLayout() {
  return (
    <Tabs
      screenOptions={{
        headerShown: false,
        tabBarActiveTintColor: colors.primary,
        tabBarInactiveTintColor: colors.textMuted,
        tabBarStyle: {
          backgroundColor: colors.surface,
          borderTopColor: colors.border,
          height: 78,
          paddingTop: 8,
          paddingBottom: 8,
        },
        tabBarLabelStyle: {
          fontSize: 11,
          fontWeight: '600',
        },
      }}>
      <Tabs.Screen
        name="index"
        options={{
          title: 'Home',
          tabBarIcon: ({ color }) => <TabIcon name="home" color={color} />,
        }}
      />
      <Tabs.Screen
        name="services"
        options={{
          title: 'Services',
          tabBarIcon: ({ color }) => <TabIcon name="server" color={color} />,
        }}
      />
      <Tabs.Screen
        name="projects"
        options={{
          title: 'Projects',
          tabBarIcon: ({ color }) => <TabIcon name="folder-open" color={color} />,
        }}
      />
      <Tabs.Screen
        name="infrastructure"
        options={{
          title: 'Infra',
          tabBarIcon: ({ color }) => <TabIcon name="sitemap" color={color} />,
        }}
      />
      <Tabs.Screen
        name="contact"
        options={{
          title: 'Contact',
          tabBarIcon: ({ color }) => <TabIcon name="envelope" color={color} />,
        }}
      />
    </Tabs>
  );
}
'@ | Set-Content "mobile\app\(tabs)\_layout.tsx" -Encoding UTF8

@'
import { PlaceholderScreen } from '../../src/components/PlaceholderScreen';
import { ScreenContainer } from '../../src/components/ScreenContainer';

export default function HomeScreen() {
  return (
    <ScreenContainer>
      <PlaceholderScreen
        eyebrow="NETSERA"
        title="Secure infrastructure. Clear operations."
        description="The mobile companion for Netsera services, projects and infrastructure."
      />
    </ScreenContainer>
  );
}
'@ | Set-Content "mobile\app\(tabs)\index.tsx" -Encoding UTF8

@'
import { PlaceholderScreen } from '../../src/components/PlaceholderScreen';
import { ScreenContainer } from '../../src/components/ScreenContainer';

export default function ServicesScreen() {
  return (
    <ScreenContainer>
      <PlaceholderScreen
        eyebrow="SERVICES"
        title="IT services"
        description="This screen will load the published Netsera services from the ASP.NET API in Phase 4."
      />
    </ScreenContainer>
  );
}
'@ | Set-Content "mobile\app\(tabs)\services.tsx" -Encoding UTF8

@'
import { PlaceholderScreen } from '../../src/components/PlaceholderScreen';
import { ScreenContainer } from '../../src/components/ScreenContainer';

export default function ProjectsScreen() {
  return (
    <ScreenContainer>
      <PlaceholderScreen
        eyebrow="PROJECTS"
        title="Selected work"
        description="Published projects will be connected to the existing Netsera API in Phase 4."
      />
    </ScreenContainer>
  );
}
'@ | Set-Content "mobile\app\(tabs)\projects.tsx" -Encoding UTF8

@'
import { PlaceholderScreen } from '../../src/components/PlaceholderScreen';
import { ScreenContainer } from '../../src/components/ScreenContainer';

export default function InfrastructureScreen() {
  return (
    <ScreenContainer>
      <PlaceholderScreen
        eyebrow="INFRASTRUCTURE"
        title="Operational visibility"
        description="Real backend health and clearly marked lab/demo infrastructure will be implemented in Phase 5."
      />
    </ScreenContainer>
  );
}
'@ | Set-Content "mobile\app\(tabs)\infrastructure.tsx" -Encoding UTF8

@'
import { PlaceholderScreen } from '../../src/components/PlaceholderScreen';
import { ScreenContainer } from '../../src/components/ScreenContainer';

export default function ContactScreen() {
  return (
    <ScreenContainer>
      <PlaceholderScreen
        eyebrow="CONTACT"
        title="Start a conversation"
        description="The production contact form will use the existing /api/contact endpoint in Phase 4."
      />
    </ScreenContainer>
  );
}
'@ | Set-Content "mobile\app\(tabs)\contact.tsx" -Encoding UTF8

# Remove demo modal if it exists.
if (Test-Path "mobile\app\modal.tsx") {
    Remove-Item "mobile\app\modal.tsx" -Force
}

# Root Expo Router layout.
@'
import { DarkTheme, ThemeProvider } from '@react-navigation/native';
import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import 'react-native-reanimated';

import { colors } from '../src/theme';

const netseraTheme = {
  ...DarkTheme,
  colors: {
    ...DarkTheme.colors,
    primary: colors.primary,
    background: colors.background,
    card: colors.surface,
    text: colors.text,
    border: colors.border,
    notification: colors.primary,
  },
};

export default function RootLayout() {
  return (
    <ThemeProvider value={netseraTheme}>
      <Stack screenOptions={{ headerShown: false }}>
        <Stack.Screen name="(tabs)" />
      </Stack>
      <StatusBar style="light" />
    </ThemeProvider>
  );
}
'@ | Set-Content "mobile\app\_layout.tsx" -Encoding UTF8

Write-Step "Adding Phase 2 documentation"

@'
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
'@ | Set-Content "mobile\README-NETSERA-MOBILE.md" -Encoding UTF8

Write-Step "Running TypeScript check"

Push-Location "mobile"
try {
    npx tsc --noEmit
    if ($LASTEXITCODE -ne 0) {
        throw "TypeScript check failed."
    }
} finally {
    Pop-Location
}

Write-Ok "TypeScript check passed."

Write-Step "Phase 2 completed"
Write-Host ""
Write-Host "Netsera Mobile foundation is ready." -ForegroundColor Green
Write-Host "Next:" -ForegroundColor White
Write-Host "  1. Start Expo:  cd mobile" -ForegroundColor Gray
Write-Host "                  npx expo start --tunnel" -ForegroundColor Gray
Write-Host "  2. Open the project again in Expo Go." -ForegroundColor Gray
Write-Host "  3. You should see 5 Netsera tabs instead of Tab One / Tab Two." -ForegroundColor Gray
Write-Host ""
Write-Host "Do NOT run npm audit fix --force." -ForegroundColor Yellow
