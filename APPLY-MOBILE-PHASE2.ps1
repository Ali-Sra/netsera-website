param(
    [string]$ProjectRoot = (Get-Location).Path
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host " NETSERA MOBILE - PHASE 2 FOUNDATION" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

Set-Location $ProjectRoot

if (!(Test-Path ".git")) {
    Write-Warning "No .git folder found in the current directory."
    Write-Warning "Run this script from the root of netsera-website."
    exit 1
}

if (!(Test-Path "frontend") -or !(Test-Path "backend")) {
    Write-Warning "frontend/ or backend/ is missing."
    Write-Warning "This does not look like the Netsera repository root."
    exit 1
}

if (Test-Path "mobile") {
    Write-Warning "The mobile folder already exists."
    Write-Warning "To avoid overwriting existing work, Phase 2 will stop here."
    Write-Warning "Rename or remove mobile/ only if you really want a fresh setup."
    exit 1
}

Write-Host "[1/8] Creating Expo + React Native + TypeScript project..." -ForegroundColor Green

# Current Expo default template includes Expo Router and TypeScript.
npx create-expo-app@latest mobile --template default --yes

if ($LASTEXITCODE -ne 0) {
    throw "create-expo-app failed."
}

Set-Location (Join-Path $ProjectRoot "mobile")

Write-Host "[2/8] Creating Netsera source structure..." -ForegroundColor Green

$folders = @(
    "src\api",
    "src\components",
    "src\constants",
    "src\hooks",
    "src\theme",
    "src\types",
    "src\utils"
)

foreach ($folder in $folders) {
    New-Item -ItemType Directory -Force -Path $folder | Out-Null
}

Write-Host "[3/8] Creating environment configuration..." -ForegroundColor Green

@'
EXPO_PUBLIC_API_BASE_URL=http://localhost:8080
'@ | Set-Content -Encoding UTF8 ".env.example"

@'
EXPO_PUBLIC_API_BASE_URL=http://localhost:8080
'@ | Set-Content -Encoding UTF8 ".env"

Write-Host "[4/8] Creating Netsera theme..." -ForegroundColor Green

@'
export const colors = {
  background: "#08111A",
  surface: "#0F1A24",
  surfaceAlt: "#132331",

  text: "#F5F7FA",
  textMuted: "#9BA9B6",

  primary: "#32D583",
  secondary: "#2E90FA",

  success: "#12B76A",
  warning: "#F79009",
  danger: "#F04438",

  border: "#22303D",
} as const;
'@ | Set-Content -Encoding UTF8 "src\theme\colors.ts"

@'
export const spacing = {
  xs: 4,
  sm: 8,
  md: 16,
  lg: 24,
  xl: 32,
  xxl: 48,
} as const;
'@ | Set-Content -Encoding UTF8 "src\theme\spacing.ts"

@'
export const radius = {
  sm: 8,
  md: 14,
  lg: 20,
  xl: 28,
} as const;
'@ | Set-Content -Encoding UTF8 "src\theme\radius.ts"

@'
export const typography = {
  title: 30,
  heading: 24,
  subheading: 18,
  body: 16,
  small: 14,
  caption: 12,
} as const;
'@ | Set-Content -Encoding UTF8 "src\theme\typography.ts"

@'
export { colors } from "./colors";
export { radius } from "./radius";
export { spacing } from "./spacing";
export { typography } from "./typography";
'@ | Set-Content -Encoding UTF8 "src\theme\index.ts"

Write-Host "[5/8] Creating typed API foundation..." -ForegroundColor Green

@'
const apiBaseUrl = process.env.EXPO_PUBLIC_API_BASE_URL;

if (!apiBaseUrl) {
  throw new Error(
    "EXPO_PUBLIC_API_BASE_URL is not configured. Add it to mobile/.env."
  );
}

export const config = {
  apiBaseUrl: apiBaseUrl.replace(/\/+$/, ""),
} as const;
'@ | Set-Content -Encoding UTF8 "src\constants\config.ts"

@'
export type ApiStatus = "idle" | "loading" | "success" | "error";

export interface ApiErrorResponse {
  message?: string;
}
'@ | Set-Content -Encoding UTF8 "src\types\api.ts"

@'
import { config } from "../constants/config";

const DEFAULT_TIMEOUT_MS = 10_000;

export class ApiError extends Error {
  readonly status?: number;

  constructor(message: string, status?: number) {
    super(message);
    this.name = "ApiError";
    this.status = status;
  }
}

async function readErrorMessage(response: Response): Promise<string> {
  try {
    const payload = (await response.json()) as { message?: string };

    if (payload?.message) {
      return payload.message;
    }
  } catch {
    // Ignore invalid/non-JSON error bodies and use the fallback below.
  }

  return `API request failed with status ${response.status}.`;
}

export async function apiRequest<T>(
  path: string,
  options: RequestInit = {}
): Promise<T> {
  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), DEFAULT_TIMEOUT_MS);

  try {
    const response = await fetch(`${config.apiBaseUrl}${path}`, {
      ...options,
      headers: {
        Accept: "application/json",
        ...(options.body ? { "Content-Type": "application/json" } : {}),
        ...options.headers,
      },
      signal: controller.signal,
    });

    if (!response.ok) {
      throw new ApiError(await readErrorMessage(response), response.status);
    }

    if (response.status === 204) {
      return undefined as T;
    }

    return (await response.json()) as T;
  } catch (error) {
    if (error instanceof ApiError) {
      throw error;
    }

    if (error instanceof Error && error.name === "AbortError") {
      throw new ApiError("The Netsera API request timed out.");
    }

    throw new ApiError(
      error instanceof Error
        ? error.message
        : "The Netsera API could not be reached."
    );
  } finally {
    clearTimeout(timeoutId);
  }
}
'@ | Set-Content -Encoding UTF8 "src\api\client.ts"

Write-Host "[6/8] Creating reusable screen container..." -ForegroundColor Green

@'
import type { PropsWithChildren } from "react";
import type { StyleProp, ViewStyle } from "react-native";
import { ScrollView, StyleSheet, View } from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";

import { colors } from "../theme/colors";
import { spacing } from "../theme/spacing";

type ScreenContainerProps = PropsWithChildren<{
  scroll?: boolean;
  contentStyle?: StyleProp<ViewStyle>;
}>;

export function ScreenContainer({
  children,
  scroll = true,
  contentStyle,
}: ScreenContainerProps) {
  if (!scroll) {
    return (
      <SafeAreaView style={styles.safeArea} edges={["top", "left", "right"]}>
        <View style={[styles.content, styles.flex, contentStyle]}>
          {children}
        </View>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.safeArea} edges={["top", "left", "right"]}>
      <ScrollView
        contentContainerStyle={[styles.content, contentStyle]}
        keyboardShouldPersistTaps="handled"
        showsVerticalScrollIndicator={false}
      >
        {children}
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: colors.background,
  },
  flex: {
    flex: 1,
  },
  content: {
    paddingHorizontal: spacing.md,
    paddingVertical: spacing.md,
  },
});
'@ | Set-Content -Encoding UTF8 "src\components\ScreenContainer.tsx"

Write-Host "[7/8] Adding Phase 2 documentation..." -ForegroundColor Green

@'
# Netsera Mobile

React Native + Expo + TypeScript mobile client for the existing Netsera platform.

## Phase 2

This phase establishes only the mobile foundation:

- Expo
- React Native
- TypeScript
- Expo Router
- reusable theme tokens
- environment configuration
- central API client
- reusable screen container

No existing Netsera backend or frontend code is replaced.

## Development

```powershell
npm install
npx expo start
```

## API configuration

Copy `.env.example` to `.env` and set:

```env
EXPO_PUBLIC_API_BASE_URL=http://localhost:8080
```

### Local addresses

Windows/Web:
`http://localhost:8080`

Android Emulator:
`http://10.0.2.2:8080`

Physical Android/iPhone on the same Wi-Fi:
use the LAN IP address of the development PC, for example:

`http://192.168.x.x:8080`

The physical phone cannot use the development PC's `localhost`.

## Security

The mobile client must communicate with ASP.NET Core through HTTP/HTTPS APIs.
It must never connect directly to PostgreSQL and must never contain database credentials.
'@ | Set-Content -Encoding UTF8 "README-NETSERA.md"

# Ensure local .env is not committed.
$gitignorePath = ".gitignore"
if (Test-Path $gitignorePath) {
    $gitignore = Get-Content $gitignorePath -Raw
    if ($gitignore -notmatch "(?m)^\.env$") {
        Add-Content -Encoding UTF8 $gitignorePath "`n# Local Netsera mobile environment`n.env`n"
    }
} else {
    @'
.env
node_modules/
.expo/
'@ | Set-Content -Encoding UTF8 $gitignorePath
}

Write-Host "[8/8] Running validation..." -ForegroundColor Green

npm install
if ($LASTEXITCODE -ne 0) {
    throw "npm install failed."
}

npx tsc --noEmit
if ($LASTEXITCODE -ne 0) {
    throw "TypeScript validation failed."
}

Write-Host ""
Write-Host "=============================================" -ForegroundColor Green
Write-Host " NETSERA MOBILE PHASE 2 COMPLETED" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green
Write-Host ""
Write-Host "Created: mobile/" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next commands:" -ForegroundColor Yellow
Write-Host "  cd mobile"
Write-Host "  npx expo start"
Write-Host ""
Write-Host "For Android Emulator, change mobile/.env to:"
Write-Host "  EXPO_PUBLIC_API_BASE_URL=http://10.0.2.2:8080"
Write-Host ""
