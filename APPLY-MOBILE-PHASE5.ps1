$ErrorActionPreference = "Stop"

Write-Host "==> Netsera Mobile - Phase 5: Real Infrastructure Dashboard" -ForegroundColor Cyan

if (-not (Test-Path ".\mobile\package.json")) {
    throw "Run this script from the netsera-website repository root."
}

New-Item -ItemType Directory -Force ".\mobile\src\api" | Out-Null

Write-Host "==> Creating real health API client" -ForegroundColor Yellow

$healthApi = @'
import { appConfig } from '../config/app';

export type HealthState = 'healthy' | 'unhealthy' | 'unreachable';

export type HealthCheckResult = {
  state: HealthState;
  status: number | null;
  message: string;
  latencyMs: number | null;
  checkedAt: string;
};

async function checkHealth(path: string): Promise<HealthCheckResult> {
  const controller = new AbortController();
  const startedAt = Date.now();
  const timeout = setTimeout(
    () => controller.abort(),
    appConfig.requestTimeoutMs,
  );

  try {
    const response = await fetch(`${appConfig.apiBaseUrl}${path}`, {
      method: 'GET',
      headers: {
        Accept: 'text/plain, application/json',
      },
      signal: controller.signal,
    });

    const latencyMs = Date.now() - startedAt;
    const body = (await response.text()).trim();

    return {
      state: response.ok ? 'healthy' : 'unhealthy',
      status: response.status,
      message: body || response.statusText || 'No response body',
      latencyMs,
      checkedAt: new Date().toISOString(),
    };
  } catch (error) {
    return {
      state: 'unreachable',
      status: null,
      message:
        error instanceof Error && error.name === 'AbortError'
          ? 'Request timed out'
          : error instanceof Error
            ? error.message
            : 'Network request failed',
      latencyMs: null,
      checkedAt: new Date().toISOString(),
    };
  } finally {
    clearTimeout(timeout);
  }
}

export const healthApi = {
  live: () => checkHealth('/health/live'),
  ready: () => checkHealth('/health/ready'),
};
'@

Set-Content -LiteralPath ".\mobile\src\api\healthApi.ts" -Value $healthApi -Encoding UTF8

Write-Host "==> Replacing Infrastructure tab with live dashboard" -ForegroundColor Yellow

$infra = @'
import { useCallback, useEffect, useState } from 'react';
import {
  ActivityIndicator,
  Pressable,
  RefreshControl,
  ScrollView,
  StyleSheet,
  Text,
  View,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import {
  healthApi,
  type HealthCheckResult,
  type HealthState,
} from '../../src/api/healthApi';
import { appConfig } from '../../src/config/app';
import { colors, radius, spacing } from '../../src/theme';

type DashboardState = {
  live: HealthCheckResult | null;
  ready: HealthCheckResult | null;
};

const AUTO_REFRESH_MS = 15000;

export default function InfrastructureScreen() {
  const [health, setHealth] = useState<DashboardState>({
    live: null,
    ready: null,
  });
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);

  const loadHealth = useCallback(async (manual = false) => {
    if (manual) setRefreshing(true);

    try {
      const [live, ready] = await Promise.all([
        healthApi.live(),
        healthApi.ready(),
      ]);

      setHealth({ live, ready });
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  }, []);

  useEffect(() => {
    void loadHealth();

    const timer = setInterval(() => {
      void loadHealth();
    }, AUTO_REFRESH_MS);

    return () => clearInterval(timer);
  }, [loadHealth]);

  const overallState = getOverallState(health.live, health.ready);

  return (
    <SafeAreaView style={styles.safeArea} edges={['top']}>
      <ScrollView
        contentContainerStyle={styles.content}
        refreshControl={
          <RefreshControl
            refreshing={refreshing}
            onRefresh={() => void loadHealth(true)}
            tintColor={colors.accent}
          />
        }
        showsVerticalScrollIndicator={false}
      >
        <View style={styles.headerRow}>
          <View style={styles.headerText}>
            <Text style={styles.eyebrow}>INFRASTRUCTURE</Text>
            <Text style={styles.title}>Operational status.</Text>
          </View>

          <StatusPill state={overallState} />
        </View>

        <Text style={styles.subtitle}>
          Real health checks from the Netsera ASP.NET API. Readiness includes
          the PostgreSQL dependency; lab telemetry remains clearly separated
          from production health.
        </Text>

        {loading && !health.live && !health.ready ? (
          <View style={styles.loadingCard}>
            <ActivityIndicator color={colors.accent} />
            <Text style={styles.loadingText}>Checking infrastructure...</Text>
          </View>
        ) : (
          <View style={styles.stack}>
            <HealthCard
              title="Backend API"
              subtitle="/health/live"
              detail="Confirms that the API process is alive and responding."
              result={health.live}
            />

            <HealthCard
              title="PostgreSQL readiness"
              subtitle="/health/ready"
              detail="Confirms the API is ready to serve requests, including its database dependency."
              result={health.ready}
            />
          </View>
        )}

        <View style={styles.section}>
          <Text style={styles.sectionLabel}>CONNECTION</Text>
          <View style={styles.infoCard}>
            <InfoRow label="API base URL" value={appConfig.apiBaseUrl} />
            <InfoRow label="Auto refresh" value="Every 15 seconds" />
            <InfoRow
              label="Last check"
              value={formatCheckedAt(health.live?.checkedAt ?? health.ready?.checkedAt)}
              last
            />
          </View>
        </View>

        <View style={styles.section}>
          <Text style={styles.sectionLabel}>LAB / DEMO</Text>
          <View style={styles.demoCard}>
            <View style={styles.demoTopRow}>
              <Text style={styles.demoTitle}>Infrastructure lab telemetry</Text>
              <View style={styles.demoBadge}>
                <Text style={styles.demoBadgeText}>DEMO</Text>
              </View>
            </View>

            <Text style={styles.demoText}>
              VMware, Hyper-V, firewall, VLAN and security telemetry are not
              connected to this mobile app yet. No simulated values are shown
              as live production data.
            </Text>
          </View>
        </View>

        <Pressable
          onPress={() => void loadHealth(true)}
          disabled={refreshing}
          style={({ pressed }) => [
            styles.refreshButton,
            pressed && styles.refreshButtonPressed,
            refreshing && styles.refreshButtonDisabled,
          ]}
        >
          {refreshing ? (
            <ActivityIndicator color={colors.background} />
          ) : (
            <Text style={styles.refreshButtonText}>Refresh status</Text>
          )}
        </Pressable>

        <Text style={styles.footerNote}>
          Live = API process health. Ready = API plus required dependencies.
        </Text>
      </ScrollView>
    </SafeAreaView>
  );
}

function HealthCard({
  title,
  subtitle,
  detail,
  result,
}: {
  title: string;
  subtitle: string;
  detail: string;
  result: HealthCheckResult | null;
}) {
  const state = result?.state ?? 'unreachable';

  return (
    <View style={styles.healthCard}>
      <View style={styles.healthCardTop}>
        <View style={styles.healthCardHeading}>
          <Text style={styles.healthTitle}>{title}</Text>
          <Text style={styles.healthEndpoint}>{subtitle}</Text>
        </View>

        <View style={styles.stateRow}>
          <View style={[styles.dot, dotStyle(state)]} />
          <Text style={[styles.stateText, stateTextStyle(state)]}>
            {stateLabel(result?.state)}
          </Text>
        </View>
      </View>

      <Text style={styles.healthDetail}>{detail}</Text>

      <View style={styles.metricsRow}>
        <Metric
          label="HTTP"
          value={result?.status ? String(result.status) : '—'}
        />
        <Metric
          label="Latency"
          value={
            result?.latencyMs !== null && result?.latencyMs !== undefined
              ? `${result.latencyMs} ms`
              : '—'
          }
        />
        <Metric
          label="Response"
          value={shortMessage(result?.message)}
        />
      </View>
    </View>
  );
}

function Metric({ label, value }: { label: string; value: string }) {
  return (
    <View style={styles.metric}>
      <Text style={styles.metricLabel}>{label}</Text>
      <Text style={styles.metricValue} numberOfLines={1}>
        {value}
      </Text>
    </View>
  );
}

function InfoRow({
  label,
  value,
  last = false,
}: {
  label: string;
  value: string;
  last?: boolean;
}) {
  return (
    <View style={[styles.infoRow, last && styles.infoRowLast]}>
      <Text style={styles.infoLabel}>{label}</Text>
      <Text style={styles.infoValue} numberOfLines={2}>
        {value}
      </Text>
    </View>
  );
}

function StatusPill({ state }: { state: HealthState | 'checking' }) {
  return (
    <View style={[styles.statusPill, pillStyle(state)]}>
      <Text style={[styles.statusPillText, pillTextStyle(state)]}>
        {state === 'healthy'
          ? 'Operational'
          : state === 'unhealthy'
            ? 'Degraded'
            : state === 'unreachable'
              ? 'Offline'
              : 'Checking'}
      </Text>
    </View>
  );
}

function getOverallState(
  live: HealthCheckResult | null,
  ready: HealthCheckResult | null,
): HealthState | 'checking' {
  if (!live || !ready) return 'checking';
  if (live.state === 'unreachable' || ready.state === 'unreachable') {
    return 'unreachable';
  }
  if (live.state === 'unhealthy' || ready.state === 'unhealthy') {
    return 'unhealthy';
  }
  return 'healthy';
}

function stateLabel(state?: HealthState) {
  if (state === 'healthy') return 'Healthy';
  if (state === 'unhealthy') return 'Unhealthy';
  if (state === 'unreachable') return 'Unreachable';
  return 'Checking';
}

function shortMessage(message?: string) {
  if (!message) return '—';
  return message.length > 18 ? `${message.slice(0, 18)}…` : message;
}

function formatCheckedAt(value?: string) {
  if (!value) return 'Not checked yet';

  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return 'Unknown';

  return date.toLocaleTimeString([], {
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit',
  });
}

function dotStyle(state: HealthState) {
  if (state === 'healthy') return styles.dotHealthy;
  if (state === 'unhealthy') return styles.dotUnhealthy;
  return styles.dotOffline;
}

function stateTextStyle(state: HealthState) {
  if (state === 'healthy') return styles.textHealthy;
  if (state === 'unhealthy') return styles.textUnhealthy;
  return styles.textOffline;
}

function pillStyle(state: HealthState | 'checking') {
  if (state === 'healthy') return styles.pillHealthy;
  if (state === 'unhealthy') return styles.pillUnhealthy;
  if (state === 'unreachable') return styles.pillOffline;
  return styles.pillChecking;
}

function pillTextStyle(state: HealthState | 'checking') {
  if (state === 'healthy') return styles.textHealthy;
  if (state === 'unhealthy') return styles.textUnhealthy;
  if (state === 'unreachable') return styles.textOffline;
  return styles.textMuted;
}

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: colors.background,
  },
  content: {
    paddingHorizontal: spacing.xl,
    paddingTop: spacing.lg,
    paddingBottom: 140,
  },
  headerRow: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    justifyContent: 'space-between',
    gap: spacing.md,
  },
  headerText: {
    flex: 1,
  },
  eyebrow: {
    color: colors.accent,
    fontSize: 15,
    fontWeight: '800',
    letterSpacing: 3,
    marginBottom: spacing.md,
  },
  title: {
    color: colors.text,
    fontSize: 42,
    lineHeight: 48,
    fontWeight: '800',
    letterSpacing: -1.1,
  },
  subtitle: {
    color: colors.textMuted,
    fontSize: 17,
    lineHeight: 26,
    marginTop: spacing.lg,
    marginBottom: spacing.xl,
  },
  statusPill: {
    borderRadius: 999,
    paddingHorizontal: 12,
    paddingVertical: 8,
    borderWidth: 1,
  },
  statusPillText: {
    fontSize: 12,
    fontWeight: '800',
  },
  pillHealthy: {
    borderColor: '#1f9d68',
    backgroundColor: 'rgba(31,157,104,0.12)',
  },
  pillUnhealthy: {
    borderColor: '#d89a30',
    backgroundColor: 'rgba(216,154,48,0.12)',
  },
  pillOffline: {
    borderColor: '#d85a5a',
    backgroundColor: 'rgba(216,90,90,0.12)',
  },
  pillChecking: {
    borderColor: colors.border,
    backgroundColor: colors.surface,
  },
  stack: {
    gap: spacing.lg,
  },
  loadingCard: {
    minHeight: 140,
    borderWidth: 1,
    borderColor: colors.border,
    borderRadius: radius.lg,
    backgroundColor: colors.surface,
    alignItems: 'center',
    justifyContent: 'center',
    gap: spacing.md,
  },
  loadingText: {
    color: colors.textMuted,
    fontSize: 15,
  },
  healthCard: {
    borderWidth: 1,
    borderColor: colors.border,
    borderRadius: radius.lg,
    backgroundColor: colors.surface,
    padding: spacing.lg,
  },
  healthCardTop: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
    gap: spacing.md,
  },
  healthCardHeading: {
    flex: 1,
  },
  healthTitle: {
    color: colors.text,
    fontSize: 20,
    fontWeight: '800',
  },
  healthEndpoint: {
    color: colors.accent,
    fontSize: 13,
    fontWeight: '700',
    marginTop: 5,
  },
  stateRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 7,
    paddingTop: 3,
  },
  dot: {
    width: 9,
    height: 9,
    borderRadius: 99,
  },
  dotHealthy: {
    backgroundColor: '#36c98f',
  },
  dotUnhealthy: {
    backgroundColor: '#f1ad43',
  },
  dotOffline: {
    backgroundColor: '#ef6b6b',
  },
  stateText: {
    fontSize: 13,
    fontWeight: '800',
  },
  textHealthy: {
    color: '#36c98f',
  },
  textUnhealthy: {
    color: '#f1ad43',
  },
  textOffline: {
    color: '#ef6b6b',
  },
  textMuted: {
    color: colors.textMuted,
  },
  healthDetail: {
    color: colors.textMuted,
    fontSize: 14,
    lineHeight: 21,
    marginTop: spacing.md,
  },
  metricsRow: {
    flexDirection: 'row',
    gap: 8,
    marginTop: spacing.lg,
  },
  metric: {
    flex: 1,
    minWidth: 0,
    borderRadius: radius.md,
    backgroundColor: colors.background,
    paddingHorizontal: 10,
    paddingVertical: 12,
  },
  metricLabel: {
    color: colors.textMuted,
    fontSize: 10,
    fontWeight: '800',
    letterSpacing: 0.8,
    textTransform: 'uppercase',
  },
  metricValue: {
    color: colors.text,
    fontSize: 13,
    fontWeight: '800',
    marginTop: 5,
  },
  section: {
    marginTop: spacing.xl,
  },
  sectionLabel: {
    color: colors.textMuted,
    fontSize: 12,
    fontWeight: '800',
    letterSpacing: 2,
    marginBottom: spacing.md,
  },
  infoCard: {
    borderWidth: 1,
    borderColor: colors.border,
    borderRadius: radius.lg,
    backgroundColor: colors.surface,
    paddingHorizontal: spacing.lg,
  },
  infoRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    gap: spacing.lg,
    paddingVertical: 15,
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: colors.border,
  },
  infoRowLast: {
    borderBottomWidth: 0,
  },
  infoLabel: {
    color: colors.textMuted,
    fontSize: 13,
  },
  infoValue: {
    color: colors.text,
    fontSize: 13,
    fontWeight: '700',
    flex: 1,
    textAlign: 'right',
  },
  demoCard: {
    borderWidth: 1,
    borderColor: colors.border,
    borderRadius: radius.lg,
    backgroundColor: colors.surface,
    padding: spacing.lg,
  },
  demoTopRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    gap: spacing.md,
  },
  demoTitle: {
    color: colors.text,
    fontSize: 17,
    fontWeight: '800',
    flex: 1,
  },
  demoBadge: {
    borderWidth: 1,
    borderColor: colors.border,
    borderRadius: 999,
    paddingHorizontal: 9,
    paddingVertical: 5,
  },
  demoBadgeText: {
    color: colors.textMuted,
    fontSize: 10,
    fontWeight: '900',
    letterSpacing: 1,
  },
  demoText: {
    color: colors.textMuted,
    fontSize: 14,
    lineHeight: 22,
    marginTop: spacing.md,
  },
  refreshButton: {
    minHeight: 56,
    borderRadius: radius.lg,
    backgroundColor: colors.accent,
    alignItems: 'center',
    justifyContent: 'center',
    marginTop: spacing.xl,
  },
  refreshButtonPressed: {
    opacity: 0.84,
  },
  refreshButtonDisabled: {
    opacity: 0.6,
  },
  refreshButtonText: {
    color: colors.background,
    fontSize: 15,
    fontWeight: '800',
  },
  footerNote: {
    color: colors.textMuted,
    fontSize: 12,
    lineHeight: 18,
    textAlign: 'center',
    marginTop: spacing.md,
  },
});
'@

Set-Content -LiteralPath ".\mobile\app\(tabs)\infra.tsx" -Value $infra -Encoding UTF8

Write-Host "==> Adding Phase 5 notes" -ForegroundColor Yellow

$notes = @'
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
'@

Set-Content -LiteralPath ".\mobile\README-PHASE5.md" -Value $notes -Encoding UTF8

Write-Host "==> Running TypeScript check" -ForegroundColor Yellow

Push-Location ".\mobile"
try {
    npx tsc --noEmit
    if ($LASTEXITCODE -ne 0) {
        throw "TypeScript check failed."
    }
}
finally {
    Pop-Location
}

Write-Host ""
Write-Host "==> Phase 5 completed successfully" -ForegroundColor Green
Write-Host ""
Write-Host "Infrastructure now shows REAL:" -ForegroundColor Cyan
Write-Host "  - API liveness"
Write-Host "  - PostgreSQL readiness"
Write-Host "  - HTTP status"
Write-Host "  - response latency"
Write-Host "  - last check time"
Write-Host "  - 15-second auto refresh"
Write-Host ""
Write-Host "Lab telemetry remains explicitly DEMO / not connected." -ForegroundColor Yellow
Write-Host ""
Write-Host "Restart Expo:" -ForegroundColor Yellow
Write-Host "  cd mobile"
Write-Host "  npx expo start --tunnel -c"
