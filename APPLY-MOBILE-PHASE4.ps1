$ErrorActionPreference = "Stop"

function Step($t) { Write-Host ""; Write-Host "==> $t" -ForegroundColor Cyan }
function Ok($t) { Write-Host "    $t" -ForegroundColor Green }

Step "Checking Netsera mobile project"

if (-not (Test-Path ".git")) {
    throw "Run this script from the netsera-website repository root."
}

if (-not (Test-Path "mobile\package.json")) {
    throw "mobile/package.json not found."
}

if (-not (Test-Path "mobile\src\api\publicApi.ts")) {
    throw "Phase 2 API foundation was not found."
}

if (-not (Test-Path "mobile\app\(tabs)\services.tsx")) {
    throw "Phase 3 screens were not found."
}

Step "Creating Phase 4 API UI components"

$dirs = @(
    "mobile\src\components\api",
    "mobile\app\project"
)

foreach ($dir in $dirs) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
}

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

export type ContactResponse = {
  id?: number;
  createdAtUtc?: string;
  status?: string;
};
'@ | Set-Content "mobile\src\types\api.ts" -Encoding UTF8

@'
import { apiFetch } from './client';
import type {
  ContactRequest,
  ContactResponse,
  Project,
  Service,
} from '../types/api';

export const publicApi = {
  getProjects: () => apiFetch<Project[]>('/api/content/projects'),

  getServices: () => apiFetch<Service[]>('/api/content/services'),

  sendContact: (payload: ContactRequest) =>
    apiFetch<ContactResponse>('/api/contact', {
      method: 'POST',
      body: JSON.stringify(payload),
    }),

  getLiveHealth: () => apiFetch<unknown>('/health/live'),

  getReadyHealth: () => apiFetch<unknown>('/health/ready'),
};
'@ | Set-Content "mobile\src\api\publicApi.ts" -Encoding UTF8

@'
import { ActivityIndicator, StyleSheet, Text, View } from 'react-native';

import { AppButton } from '../ui/AppButton';
import { colors, spacing, typography } from '../../theme';

type Props = {
  message?: string;
  onRetry?: () => void;
};

export function LoadingState({ message = 'Loading…' }: { message?: string }) {
  return (
    <View style={styles.center}>
      <ActivityIndicator size="small" color={colors.primary} />
      <Text style={styles.message}>{message}</Text>
    </View>
  );
}

export function ErrorState({
  message = 'Something went wrong.',
  onRetry,
}: Props) {
  return (
    <View style={styles.center}>
      <Text style={styles.errorTitle}>Unable to load data</Text>
      <Text style={styles.message}>{message}</Text>
      {onRetry ? <AppButton onPress={onRetry}>Try again</AppButton> : null}
    </View>
  );
}

export function EmptyState({ message }: { message: string }) {
  return (
    <View style={styles.center}>
      <Text style={styles.emptyTitle}>Nothing published yet</Text>
      <Text style={styles.message}>{message}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  center: {
    paddingVertical: spacing.xxl,
    gap: spacing.md,
    alignItems: 'center',
  },
  errorTitle: {
    color: colors.danger,
    ...typography.bodyStrong,
  },
  emptyTitle: {
    color: colors.text,
    ...typography.bodyStrong,
  },
  message: {
    color: colors.textMuted,
    ...typography.body,
    textAlign: 'center',
  },
});
'@ | Set-Content "mobile\src\components\api\RequestStates.tsx" -Encoding UTF8


Step "Repairing reusable AppCard typing for conditional styles"

@'
import type { PropsWithChildren } from 'react';
import {
  StyleSheet,
  View,
  type StyleProp,
  type ViewStyle,
} from 'react-native';
import { colors, radius, spacing } from '../../theme';

export function AppCard({
  children,
  style,
}: PropsWithChildren<{ style?: StyleProp<ViewStyle> }>) {
  return <View style={[styles.card, style]}>{children}</View>;
}

const styles = StyleSheet.create({
  card: {
    backgroundColor: colors.surface,
    borderWidth: 1,
    borderColor: colors.border,
    borderRadius: radius.lg,
    padding: spacing.lg,
  },
});
'@ | Set-Content "mobile\src\components\ui\AppCard.tsx" -Encoding UTF8

Step "Connecting Services screen to the real API"

@'
import { useCallback, useEffect, useState } from 'react';
import { RefreshControl, ScrollView, StyleSheet, Text, View } from 'react-native';
import FontAwesome from '@expo/vector-icons/FontAwesome';

import { publicApi } from '../../src/api';
import {
  EmptyState,
  ErrorState,
  LoadingState,
} from '../../src/components/api/RequestStates';
import { AppCard } from '../../src/components/ui/AppCard';
import { ScreenContainer } from '../../src/components/ScreenContainer';
import type { Service } from '../../src/types/api';
import { colors, spacing, typography } from '../../src/theme';

function iconForService(icon?: string | null): React.ComponentProps<typeof FontAwesome>['name'] {
  const normalized = icon?.toLowerCase() ?? '';

  if (normalized.includes('security') || normalized.includes('shield')) return 'shield';
  if (normalized.includes('network')) return 'sitemap';
  if (normalized.includes('server')) return 'server';
  if (normalized.includes('cloud')) return 'cloud';
  if (normalized.includes('microsoft') || normalized.includes('windows')) return 'windows';

  return 'cogs';
}

export default function ServicesScreen() {
  const [items, setItems] = useState<Service[]>([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const load = useCallback(async (refresh = false) => {
    if (refresh) setRefreshing(true);
    else setLoading(true);

    setError(null);

    try {
      const data = await publicApi.getServices();
      setItems(data);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unknown API error');
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  }, []);

  useEffect(() => {
    void load();
  }, [load]);

  return (
    <ScreenContainer>
      <ScrollView
        contentContainerStyle={styles.content}
        refreshControl={
          <RefreshControl
            refreshing={refreshing}
            onRefresh={() => void load(true)}
            tintColor={colors.primary}
          />
        }>
        <Text style={styles.eyebrow}>SERVICES</Text>
        <Text style={styles.title}>Infrastructure expertise, clearly structured.</Text>
        <Text style={styles.description}>
          Published services are loaded directly from the Netsera ASP.NET API.
        </Text>

        {loading ? <LoadingState message="Loading services…" /> : null}

        {!loading && error ? (
          <ErrorState message={error} onRetry={() => void load()} />
        ) : null}

        {!loading && !error && items.length === 0 ? (
          <EmptyState message="No services are currently published." />
        ) : null}

        {!loading && !error && items.length > 0 ? (
          <View style={styles.list}>
            {items.map((item) => (
              <AppCard key={item.id} style={styles.card}>
                <View style={styles.iconBox}>
                  <FontAwesome
                    name={iconForService(item.icon)}
                    size={22}
                    color={colors.primary}
                  />
                </View>

                <View style={styles.cardText}>
                  <Text style={styles.cardTitle}>{item.title}</Text>
                  <Text style={styles.cardDescription}>
                    {item.description || 'Service details will be added soon.'}
                  </Text>
                </View>
              </AppCard>
            ))}
          </View>
        ) : null}
      </ScrollView>
    </ScreenContainer>
  );
}

const styles = StyleSheet.create({
  content: {
    padding: spacing.lg,
    paddingBottom: 120,
    gap: spacing.md,
  },
  eyebrow: {
    color: colors.primary,
    ...typography.label,
  },
  title: {
    color: colors.text,
    ...typography.h1,
  },
  description: {
    color: colors.textMuted,
    ...typography.body,
  },
  list: {
    gap: spacing.md,
    marginTop: spacing.md,
  },
  card: {
    flexDirection: 'row',
    gap: spacing.md,
    alignItems: 'flex-start',
  },
  iconBox: {
    width: 44,
    height: 44,
    borderRadius: 12,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: colors.surfaceElevated,
  },
  cardText: {
    flex: 1,
    gap: 6,
  },
  cardTitle: {
    color: colors.text,
    ...typography.bodyStrong,
  },
  cardDescription: {
    color: colors.textMuted,
    ...typography.body,
  },
});
'@ | Set-Content "mobile\app\(tabs)\services.tsx" -Encoding UTF8

Step "Connecting Projects screen to the real API"

@'
import { useCallback, useEffect, useState } from 'react';
import {
  Pressable,
  RefreshControl,
  ScrollView,
  StyleSheet,
  Text,
} from 'react-native';
import { router } from 'expo-router';

import { publicApi } from '../../src/api';
import {
  EmptyState,
  ErrorState,
  LoadingState,
} from '../../src/components/api/RequestStates';
import { AppCard } from '../../src/components/ui/AppCard';
import { ScreenContainer } from '../../src/components/ScreenContainer';
import type { Project } from '../../src/types/api';
import { colors, spacing, typography } from '../../src/theme';

export default function ProjectsScreen() {
  const [items, setItems] = useState<Project[]>([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const load = useCallback(async (refresh = false) => {
    if (refresh) setRefreshing(true);
    else setLoading(true);

    setError(null);

    try {
      const data = await publicApi.getProjects();
      setItems(data);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unknown API error');
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  }, []);

  useEffect(() => {
    void load();
  }, [load]);

  return (
    <ScreenContainer>
      <ScrollView
        contentContainerStyle={styles.content}
        refreshControl={
          <RefreshControl
            refreshing={refreshing}
            onRefresh={() => void load(true)}
            tintColor={colors.primary}
          />
        }>
        <Text style={styles.eyebrow}>PROJECTS</Text>
        <Text style={styles.title}>Selected technical work.</Text>
        <Text style={styles.description}>
          Published projects are loaded directly from the Netsera backend.
        </Text>

        {loading ? <LoadingState message="Loading projects…" /> : null}

        {!loading && error ? (
          <ErrorState message={error} onRetry={() => void load()} />
        ) : null}

        {!loading && !error && items.length === 0 ? (
          <EmptyState message="No projects are currently published." />
        ) : null}

        {!loading && !error
          ? items.map((item, index) => (
              <Pressable
                key={item.id}
                onPress={() =>
                  router.push(`/project/${encodeURIComponent(item.slug)}` as never)
                }>
                {({ pressed }) => (
                  <AppCard style={[styles.card, pressed && styles.pressed]}>
                    <Text style={styles.index}>
                      {String(index + 1).padStart(2, '0')}
                    </Text>
                    <Text style={styles.cardTitle}>{item.title}</Text>
                    <Text style={styles.cardText}>
                      {item.shortDescription ||
                        item.description ||
                        'Project details will be added soon.'}
                    </Text>
                    <Text style={styles.openLabel}>OPEN PROJECT →</Text>
                  </AppCard>
                )}
              </Pressable>
            ))
          : null}
      </ScrollView>
    </ScreenContainer>
  );
}

const styles = StyleSheet.create({
  content: {
    padding: spacing.lg,
    paddingBottom: 120,
    gap: spacing.md,
  },
  eyebrow: {
    color: colors.primary,
    ...typography.label,
  },
  title: {
    color: colors.text,
    ...typography.h1,
  },
  description: {
    color: colors.textMuted,
    ...typography.body,
    marginBottom: spacing.md,
  },
  card: {
    gap: spacing.sm,
  },
  pressed: {
    opacity: 0.82,
  },
  index: {
    color: colors.primary,
    ...typography.label,
  },
  cardTitle: {
    color: colors.text,
    ...typography.h2,
  },
  cardText: {
    color: colors.textMuted,
    ...typography.body,
  },
  openLabel: {
    color: colors.primary,
    ...typography.small,
    marginTop: spacing.sm,
  },
});
'@ | Set-Content "mobile\app\(tabs)\projects.tsx" -Encoding UTF8

Step "Creating real project detail screen"

New-Item -ItemType Directory -Force -Path "mobile\app\project\[slug]" | Out-Null

@'
import { useEffect, useMemo, useState } from 'react';
import {
  Linking,
  ScrollView,
  StyleSheet,
  Text,
  View,
} from 'react-native';
import { Stack, useLocalSearchParams } from 'expo-router';

import { publicApi } from '../../../src/api';
import {
  ErrorState,
  LoadingState,
} from '../../../src/components/api/RequestStates';
import { AppButton } from '../../../src/components/ui/AppButton';
import { AppCard } from '../../../src/components/ui/AppCard';
import { ScreenContainer } from '../../../src/components/ScreenContainer';
import type { Project } from '../../../src/types/api';
import { colors, spacing, typography } from '../../../src/theme';

export default function ProjectDetailScreen() {
  const params = useLocalSearchParams<{ slug?: string | string[] }>();
  const slug = useMemo(
    () => (Array.isArray(params.slug) ? params.slug[0] : params.slug),
    [params.slug],
  );

  const [items, setItems] = useState<Project[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let active = true;

    async function load() {
      setLoading(true);
      setError(null);

      try {
        const data = await publicApi.getProjects();
        if (active) setItems(data);
      } catch (err) {
        if (active) {
          setError(err instanceof Error ? err.message : 'Unknown API error');
        }
      } finally {
        if (active) setLoading(false);
      }
    }

    void load();

    return () => {
      active = false;
    };
  }, []);

  const project = items.find((item) => item.slug === slug);

  return (
    <ScreenContainer>
      <Stack.Screen
        options={{
          headerShown: true,
          title: project?.title ?? 'Project',
          headerStyle: { backgroundColor: colors.surface },
          headerTintColor: colors.text,
          headerShadowVisible: false,
        }}
      />

      <ScrollView contentContainerStyle={styles.content}>
        {loading ? <LoadingState message="Loading project…" /> : null}

        {!loading && error ? <ErrorState message={error} /> : null}

        {!loading && !error && !project ? (
          <ErrorState message="The requested project could not be found." />
        ) : null}

        {!loading && !error && project ? (
          <>
            <Text style={styles.eyebrow}>PROJECT</Text>
            <Text style={styles.title}>{project.title}</Text>

            {project.shortDescription ? (
              <Text style={styles.lead}>{project.shortDescription}</Text>
            ) : null}

            <AppCard style={styles.card}>
              <Text style={styles.sectionTitle}>Overview</Text>
              <Text style={styles.body}>
                {project.description ||
                  project.shortDescription ||
                  'No detailed description has been published yet.'}
              </Text>
            </AppCard>

            <View style={styles.actions}>
              {project.projectUrl ? (
                <AppButton onPress={() => void Linking.openURL(project.projectUrl!)}>
                  Open project
                </AppButton>
              ) : null}

              {project.githubUrl ? (
                <AppButton
                  variant="secondary"
                  onPress={() => void Linking.openURL(project.githubUrl!)}>
                  Open GitHub
                </AppButton>
              ) : null}
            </View>
          </>
        ) : null}
      </ScrollView>
    </ScreenContainer>
  );
}

const styles = StyleSheet.create({
  content: {
    padding: spacing.lg,
    paddingBottom: 80,
    gap: spacing.md,
  },
  eyebrow: {
    color: colors.primary,
    ...typography.label,
  },
  title: {
    color: colors.text,
    ...typography.h1,
  },
  lead: {
    color: colors.textMuted,
    ...typography.body,
  },
  card: {
    gap: spacing.sm,
    marginTop: spacing.md,
  },
  sectionTitle: {
    color: colors.text,
    ...typography.h2,
  },
  body: {
    color: colors.textMuted,
    ...typography.body,
  },
  actions: {
    gap: spacing.sm,
  },
});
'@ | Set-Content -LiteralPath "mobile\app\project\[slug]\index.tsx" -Encoding UTF8

Step "Connecting Contact screen to the real API"

@'
import { useMemo, useState } from 'react';
import {
  Alert,
  KeyboardAvoidingView,
  Platform,
  ScrollView,
  StyleSheet,
  Text,
  TextInput,
  View,
} from 'react-native';

import { ApiError, publicApi } from '../../src/api';
import { AppButton } from '../../src/components/ui/AppButton';
import { ScreenContainer } from '../../src/components/ScreenContainer';
import { colors, radius, spacing, typography } from '../../src/theme';

export default function ContactScreen() {
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [subject, setSubject] = useState('');
  const [message, setMessage] = useState('');
  const [sending, setSending] = useState(false);
  const [success, setSuccess] = useState(false);

  const canSubmit = useMemo(() => {
    const emailOk = /^\S+@\S+\.\S+$/.test(email.trim());

    return (
      name.trim().length >= 2 &&
      emailOk &&
      message.trim().length >= 10 &&
      !sending
    );
  }, [email, message, name, sending]);

  async function submit() {
    if (!canSubmit) {
      Alert.alert(
        'Check the form',
        'Name, a valid email address and a message of at least 10 characters are required.',
      );
      return;
    }

    setSending(true);
    setSuccess(false);

    try {
      await publicApi.sendContact({
        name: name.trim(),
        email: email.trim(),
        subject: subject.trim() || undefined,
        message: message.trim(),
      });

      setSuccess(true);
      setName('');
      setEmail('');
      setSubject('');
      setMessage('');

      Alert.alert(
        'Message sent',
        'Your message was successfully sent to Netsera.',
      );
    } catch (err) {
      let text = 'The message could not be sent. Please try again.';

      if (err instanceof ApiError) {
        if (err.status === 429) {
          text = 'Too many requests. Please wait a little and try again.';
        } else {
          text = err.message || text;
        }
      } else if (err instanceof Error) {
        text = err.message;
      }

      Alert.alert('Send failed', text);
    } finally {
      setSending(false);
    }
  }

  return (
    <ScreenContainer>
      <KeyboardAvoidingView
        style={styles.flex}
        behavior={Platform.OS === 'ios' ? 'padding' : undefined}>
        <ScrollView
          contentContainerStyle={styles.content}
          keyboardShouldPersistTaps="handled">
          <Text style={styles.eyebrow}>CONTACT</Text>
          <Text style={styles.title}>Start a conversation.</Text>
          <Text style={styles.description}>
            This form now submits directly to the existing Netsera backend.
          </Text>

          {success ? (
            <View style={styles.successBox}>
              <View style={styles.successDot} />
              <Text style={styles.successText}>
                Your last message was sent successfully.
              </Text>
            </View>
          ) : null}

          <View style={styles.form}>
            <TextInput
              value={name}
              onChangeText={setName}
              placeholder="Name"
              placeholderTextColor={colors.textMuted}
              autoCapitalize="words"
              style={styles.input}
            />

            <TextInput
              value={email}
              onChangeText={setEmail}
              placeholder="Email"
              placeholderTextColor={colors.textMuted}
              keyboardType="email-address"
              autoCapitalize="none"
              autoCorrect={false}
              style={styles.input}
            />

            <TextInput
              value={subject}
              onChangeText={setSubject}
              placeholder="Subject (optional)"
              placeholderTextColor={colors.textMuted}
              style={styles.input}
            />

            <TextInput
              value={message}
              onChangeText={setMessage}
              placeholder="Message"
              placeholderTextColor={colors.textMuted}
              multiline
              textAlignVertical="top"
              style={[styles.input, styles.message]}
            />

            <Text style={styles.helper}>
              Message: {message.trim().length}/5000 characters
            </Text>

            <AppButton onPress={() => void submit()}>
              {sending ? 'Sending…' : 'Send message'}
            </AppButton>
          </View>
        </ScrollView>
      </KeyboardAvoidingView>
    </ScreenContainer>
  );
}

const styles = StyleSheet.create({
  flex: {
    flex: 1,
  },
  content: {
    padding: spacing.lg,
    paddingBottom: 140,
    gap: spacing.md,
  },
  eyebrow: {
    color: colors.primary,
    ...typography.label,
  },
  title: {
    color: colors.text,
    ...typography.h1,
  },
  description: {
    color: colors.textMuted,
    ...typography.body,
  },
  successBox: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: spacing.sm,
    padding: spacing.md,
    borderRadius: radius.md,
    borderWidth: 1,
    borderColor: colors.border,
    backgroundColor: colors.surface,
  },
  successDot: {
    width: 9,
    height: 9,
    borderRadius: 999,
    backgroundColor: colors.success,
  },
  successText: {
    flex: 1,
    color: colors.text,
    ...typography.small,
  },
  form: {
    gap: spacing.md,
    marginTop: spacing.md,
  },
  input: {
    minHeight: 52,
    backgroundColor: colors.surface,
    borderWidth: 1,
    borderColor: colors.border,
    borderRadius: radius.md,
    paddingHorizontal: spacing.md,
    color: colors.text,
    ...typography.body,
  },
  message: {
    minHeight: 150,
    paddingTop: spacing.md,
  },
  helper: {
    color: colors.textMuted,
    ...typography.small,
  },
});
'@ | Set-Content "mobile\app\(tabs)\contact.tsx" -Encoding UTF8

Step "Adding Phase 4 environment guidance"

@'
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
'@ | Set-Content "mobile\README-PHASE4.md" -Encoding UTF8

Step "Running TypeScript check"

Push-Location "mobile"
try {
    npx tsc --noEmit

    if ($LASTEXITCODE -ne 0) {
        throw "TypeScript check failed."
    }
}
finally {
    Pop-Location
}

Ok "TypeScript check passed."

Step "Phase 4 code completed"

Write-Host ""
Write-Host "Phase 4 API integration code is ready." -ForegroundColor Green
Write-Host ""
Write-Host "IMPORTANT before testing real API data on iPhone:" -ForegroundColor Yellow
Write-Host "  mobile\.env currently may still use localhost." -ForegroundColor Yellow
Write-Host "  A physical iPhone needs the Windows PC LAN IPv4 address." -ForegroundColor Yellow
Write-Host ""
Write-Host "Next commands:" -ForegroundColor White
Write-Host "  cd mobile" -ForegroundColor Gray
Write-Host "  npx expo start --tunnel" -ForegroundColor Gray
Write-Host ""
Write-Host "Do not run npm audit fix --force." -ForegroundColor Yellow
