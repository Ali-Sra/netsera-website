$ErrorActionPreference = "Stop"

function Step($t) { Write-Host ""; Write-Host "==> $t" -ForegroundColor Cyan }
function Ok($t) { Write-Host "    $t" -ForegroundColor Green }

Step "Checking Netsera mobile project"
if (-not (Test-Path ".git")) { throw "Run from netsera-website repository root." }
if (-not (Test-Path "mobile\package.json")) { throw "mobile/package.json not found." }
if (-not (Test-Path "mobile\app\(tabs)\index.tsx")) { throw "Phase 2 tabs not found." }

Step "Creating Phase 3 UI components"

$dirs = @(
  "mobile\src\components\ui",
  "mobile\src\components\home",
  "mobile\src\data"
)
foreach ($d in $dirs) { New-Item -ItemType Directory -Force -Path $d | Out-Null }

@'
export const typography = {
  display: {
    fontSize: 42,
    lineHeight: 48,
    fontWeight: '800' as const,
    letterSpacing: -1.2,
  },
  h1: {
    fontSize: 32,
    lineHeight: 38,
    fontWeight: '800' as const,
  },
  h2: {
    fontSize: 24,
    lineHeight: 30,
    fontWeight: '700' as const,
  },
  body: {
    fontSize: 16,
    lineHeight: 24,
    fontWeight: '400' as const,
  },
  bodyStrong: {
    fontSize: 16,
    lineHeight: 24,
    fontWeight: '600' as const,
  },
  small: {
    fontSize: 13,
    lineHeight: 18,
    fontWeight: '500' as const,
  },
  label: {
    fontSize: 12,
    lineHeight: 16,
    fontWeight: '700' as const,
    letterSpacing: 1.5,
  },
} as const;
'@ | Set-Content "mobile\src\theme\typography.ts" -Encoding UTF8

@'
export { colors } from './colors';
export { radius, spacing } from './layout';
export { typography } from './typography';
'@ | Set-Content "mobile\src\theme\index.ts" -Encoding UTF8

@'
import type { PropsWithChildren } from 'react';
import { Pressable, StyleSheet, Text, type ViewStyle } from 'react-native';
import { colors, radius, spacing, typography } from '../../theme';

type Props = PropsWithChildren<{
  onPress?: () => void;
  variant?: 'primary' | 'secondary';
  style?: ViewStyle;
}>;

export function AppButton({ children, onPress, variant = 'primary', style }: Props) {
  return (
    <Pressable
      onPress={onPress}
      style={({ pressed }) => [
        styles.base,
        variant === 'primary' ? styles.primary : styles.secondary,
        pressed && styles.pressed,
        style,
      ]}>
      <Text style={[styles.text, variant === 'secondary' && styles.secondaryText]}>
        {children}
      </Text>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  base: {
    minHeight: 50,
    borderRadius: radius.md,
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: spacing.lg,
  },
  primary: {
    backgroundColor: colors.primary,
  },
  secondary: {
    backgroundColor: colors.surface,
    borderWidth: 1,
    borderColor: colors.border,
  },
  pressed: {
    opacity: 0.85,
  },
  text: {
    color: colors.background,
    ...typography.bodyStrong,
  },
  secondaryText: {
    color: colors.text,
  },
});
'@ | Set-Content "mobile\src\components\ui\AppButton.tsx" -Encoding UTF8

@'
import type { PropsWithChildren } from 'react';
import { StyleSheet, View, type ViewStyle } from 'react-native';
import { colors, radius, spacing } from '../../theme';

export function AppCard({ children, style }: PropsWithChildren<{ style?: ViewStyle }>) {
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

@'
import { StyleSheet, Text, View } from 'react-native';
import { colors, spacing, typography } from '../../theme';

type Props = {
  eyebrow?: string;
  title: string;
  description?: string;
};

export function SectionHeader({ eyebrow, title, description }: Props) {
  return (
    <View style={styles.wrapper}>
      {eyebrow ? <Text style={styles.eyebrow}>{eyebrow}</Text> : null}
      <Text style={styles.title}>{title}</Text>
      {description ? <Text style={styles.description}>{description}</Text> : null}
    </View>
  );
}

const styles = StyleSheet.create({
  wrapper: {
    gap: spacing.sm,
  },
  eyebrow: {
    color: colors.primary,
    ...typography.label,
  },
  title: {
    color: colors.text,
    ...typography.h2,
  },
  description: {
    color: colors.textMuted,
    ...typography.body,
  },
});
'@ | Set-Content "mobile\src\components\ui\SectionHeader.tsx" -Encoding UTF8

@'
import { StyleSheet, Text, View } from 'react-native';
import FontAwesome from '@expo/vector-icons/FontAwesome';
import { colors, radius, spacing, typography } from '../../theme';

type Props = {
  icon: React.ComponentProps<typeof FontAwesome>['name'];
  title: string;
  description: string;
};

export function FeatureCard({ icon, title, description }: Props) {
  return (
    <View style={styles.card}>
      <View style={styles.iconBox}>
        <FontAwesome name={icon} size={18} color={colors.primary} />
      </View>
      <Text style={styles.title}>{title}</Text>
      <Text style={styles.description}>{description}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  card: {
    flex: 1,
    minWidth: 150,
    backgroundColor: colors.surface,
    borderWidth: 1,
    borderColor: colors.border,
    borderRadius: radius.lg,
    padding: spacing.md,
    gap: spacing.sm,
  },
  iconBox: {
    width: 36,
    height: 36,
    borderRadius: radius.md,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: colors.surfaceElevated,
  },
  title: {
    color: colors.text,
    ...typography.bodyStrong,
  },
  description: {
    color: colors.textMuted,
    ...typography.small,
  },
});
'@ | Set-Content "mobile\src\components\ui\FeatureCard.tsx" -Encoding UTF8

@'
export const homeStats = [
  { value: 'M365', label: 'Identity & Collaboration' },
  { value: 'AD', label: 'Windows Infrastructure' },
  { value: 'VM', label: 'Virtualization' },
  { value: 'SEC', label: 'Network Security' },
] as const;

export const serviceHighlights = [
  {
    icon: 'windows',
    title: 'Microsoft Stack',
    description: 'Windows Server, Active Directory, Microsoft 365 and Entra ID.',
  },
  {
    icon: 'server',
    title: 'Infrastructure',
    description: 'Virtualization, systems operations and reliable service delivery.',
  },
  {
    icon: 'shield',
    title: 'Security',
    description: 'Firewalling, segmentation, hardening and operational visibility.',
  },
  {
    icon: 'sitemap',
    title: 'Networking',
    description: 'Routing, switching, VLANs and practical troubleshooting.',
  },
] as const;
'@ | Set-Content "mobile\src\data\home.ts" -Encoding UTF8

@'
import { ScrollView, StyleSheet, Text, View } from 'react-native';
import { router } from 'expo-router';
import FontAwesome from '@expo/vector-icons/FontAwesome';

import { AppButton } from '../../src/components/ui/AppButton';
import { AppCard } from '../../src/components/ui/AppCard';
import { FeatureCard } from '../../src/components/ui/FeatureCard';
import { SectionHeader } from '../../src/components/ui/SectionHeader';
import { ScreenContainer } from '../../src/components/ScreenContainer';
import { homeStats, serviceHighlights } from '../../src/data/home';
import { colors, radius, spacing, typography } from '../../src/theme';

export default function HomeScreen() {
  return (
    <ScreenContainer>
      <ScrollView
        contentContainerStyle={styles.content}
        showsVerticalScrollIndicator={false}>
        <View style={styles.brandRow}>
          <View>
            <Text style={styles.brand}>NETSERA</Text>
            <Text style={styles.brandSub}>INFRASTRUCTURE SYSTEMS</Text>
          </View>
          <View style={styles.statusPill}>
            <View style={styles.statusDot} />
            <Text style={styles.statusText}>Ready</Text>
          </View>
        </View>

        <View style={styles.hero}>
          <Text style={styles.eyebrow}>INFRASTRUCTURE / SECURITY / OPERATIONS</Text>
          <Text style={styles.heroTitle}>
            Secure IT infrastructure for modern teams.
          </Text>
          <Text style={styles.heroText}>
            Netsera combines system administration, Microsoft 365, networking,
            virtualization and security into one clear operational view.
          </Text>

          <View style={styles.ctaRow}>
            <AppButton
              style={styles.cta}
              onPress={() => router.push('/contact')}>
              Start a conversation
            </AppButton>
            <AppButton
              variant="secondary"
              style={styles.cta}
              onPress={() => router.push('/services')}>
              Explore services
            </AppButton>
          </View>
        </View>

        <View style={styles.statsGrid}>
          {homeStats.map((item) => (
            <AppCard key={item.value} style={styles.statCard}>
              <Text style={styles.statValue}>{item.value}</Text>
              <Text style={styles.statLabel}>{item.label}</Text>
            </AppCard>
          ))}
        </View>

        <SectionHeader
          eyebrow="CAPABILITIES"
          title="Built around reliable operations"
          description="A practical stack for day-to-day infrastructure, support and security work."
        />

        <View style={styles.featureGrid}>
          {serviceHighlights.map((item) => (
            <FeatureCard
              key={item.title}
              icon={item.icon}
              title={item.title}
              description={item.description}
            />
          ))}
        </View>

        <AppCard style={styles.infraCard}>
          <View style={styles.infraHeader}>
            <View>
              <Text style={styles.infraEyebrow}>INFRASTRUCTURE</Text>
              <Text style={styles.infraTitle}>Operational visibility</Text>
            </View>
            <FontAwesome name="signal" size={20} color={colors.primary} />
          </View>

          <View style={styles.healthRow}>
            <View style={styles.healthItem}>
              <View style={[styles.healthDot, { backgroundColor: colors.success }]} />
              <Text style={styles.healthText}>Backend health</Text>
            </View>
            <Text style={styles.healthState}>Prepared</Text>
          </View>

          <View style={styles.healthRow}>
            <View style={styles.healthItem}>
              <View style={[styles.healthDot, { backgroundColor: colors.warning }]} />
              <Text style={styles.healthText}>Lab telemetry</Text>
            </View>
            <Text style={styles.healthState}>Phase 5</Text>
          </View>

          <AppButton
            variant="secondary"
            onPress={() => router.push('/infrastructure')}>
            Open infrastructure
          </AppButton>
        </AppCard>

        <View style={styles.footer}>
          <Text style={styles.footerTitle}>Clear systems. Better operations.</Text>
          <Text style={styles.footerText}>
            Mobile interface foundation for the Netsera platform.
          </Text>
        </View>
      </ScrollView>
    </ScreenContainer>
  );
}

const styles = StyleSheet.create({
  content: {
    paddingHorizontal: spacing.lg,
    paddingTop: spacing.lg,
    paddingBottom: 120,
    gap: spacing.xl,
  },
  brandRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  brand: {
    color: colors.primary,
    ...typography.label,
    fontSize: 15,
    letterSpacing: 3,
  },
  brandSub: {
    color: colors.textMuted,
    fontSize: 10,
    fontWeight: '700',
    letterSpacing: 1.2,
    marginTop: 2,
  },
  statusPill: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 7,
    backgroundColor: colors.surface,
    borderWidth: 1,
    borderColor: colors.border,
    borderRadius: radius.pill,
    paddingHorizontal: 12,
    paddingVertical: 8,
  },
  statusDot: {
    width: 8,
    height: 8,
    borderRadius: 999,
    backgroundColor: colors.success,
  },
  statusText: {
    color: colors.text,
    ...typography.small,
  },
  hero: {
    gap: spacing.md,
  },
  eyebrow: {
    color: colors.primary,
    ...typography.label,
  },
  heroTitle: {
    color: colors.text,
    ...typography.display,
  },
  heroText: {
    color: colors.textMuted,
    ...typography.body,
  },
  ctaRow: {
    gap: spacing.sm,
    marginTop: spacing.sm,
  },
  cta: {
    width: '100%',
  },
  statsGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: spacing.sm,
  },
  statCard: {
    width: '48%',
    minHeight: 116,
    justifyContent: 'space-between',
  },
  statValue: {
    color: colors.primary,
    fontSize: 25,
    fontWeight: '800',
  },
  statLabel: {
    color: colors.textMuted,
    ...typography.small,
  },
  featureGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: spacing.sm,
  },
  infraCard: {
    gap: spacing.md,
  },
  infraHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  infraEyebrow: {
    color: colors.primary,
    ...typography.label,
  },
  infraTitle: {
    color: colors.text,
    ...typography.h2,
    marginTop: 4,
  },
  healthRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingVertical: spacing.sm,
    borderBottomWidth: 1,
    borderBottomColor: colors.border,
  },
  healthItem: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: spacing.sm,
  },
  healthDot: {
    width: 8,
    height: 8,
    borderRadius: 999,
  },
  healthText: {
    color: colors.text,
    ...typography.bodyStrong,
  },
  healthState: {
    color: colors.textMuted,
    ...typography.small,
  },
  footer: {
    paddingVertical: spacing.lg,
    gap: spacing.sm,
  },
  footerTitle: {
    color: colors.text,
    ...typography.h2,
  },
  footerText: {
    color: colors.textMuted,
    ...typography.body,
  },
});
'@ | Set-Content "mobile\app\(tabs)\index.tsx" -Encoding UTF8

@'
import { ScrollView, StyleSheet, Text, View } from 'react-native';
import FontAwesome from '@expo/vector-icons/FontAwesome';

import { AppCard } from '../../src/components/ui/AppCard';
import { ScreenContainer } from '../../src/components/ScreenContainer';
import { serviceHighlights } from '../../src/data/home';
import { colors, spacing, typography } from '../../src/theme';

export default function ServicesScreen() {
  return (
    <ScreenContainer>
      <ScrollView contentContainerStyle={styles.content}>
        <Text style={styles.eyebrow}>SERVICES</Text>
        <Text style={styles.title}>Infrastructure expertise, clearly structured.</Text>
        <Text style={styles.description}>
          The final data will come from the existing Netsera API in Phase 4.
        </Text>

        <View style={styles.list}>
          {serviceHighlights.map((item) => (
            <AppCard key={item.title} style={styles.card}>
              <View style={styles.iconBox}>
                <FontAwesome name={item.icon} size={22} color={colors.primary} />
              </View>
              <View style={styles.cardText}>
                <Text style={styles.cardTitle}>{item.title}</Text>
                <Text style={styles.cardDescription}>{item.description}</Text>
              </View>
            </AppCard>
          ))}
        </View>
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
  eyebrow: { color: colors.primary, ...typography.label },
  title: { color: colors.text, ...typography.h1 },
  description: { color: colors.textMuted, ...typography.body },
  list: { gap: spacing.md, marginTop: spacing.md },
  card: { flexDirection: 'row', gap: spacing.md, alignItems: 'flex-start' },
  iconBox: {
    width: 44,
    height: 44,
    borderRadius: 12,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: colors.surfaceElevated,
  },
  cardText: { flex: 1, gap: 6 },
  cardTitle: { color: colors.text, ...typography.bodyStrong },
  cardDescription: { color: colors.textMuted, ...typography.body },
});
'@ | Set-Content "mobile\app\(tabs)\services.tsx" -Encoding UTF8

@'
import { ScrollView, StyleSheet, Text } from 'react-native';

import { AppCard } from '../../src/components/ui/AppCard';
import { ScreenContainer } from '../../src/components/ScreenContainer';
import { colors, spacing, typography } from '../../src/theme';

const projects = [
  {
    title: 'Virtual Infrastructure Lab',
    text: 'A practical lab environment for virtualization, networks, Windows infrastructure and operations workflows.',
  },
  {
    title: 'Enterprise Firewall Security Lab',
    text: 'A portfolio lab focused on segmentation, NAT, filtering, VPN and firewall operations.',
  },
  {
    title: 'Netsera Platform',
    text: 'Full-stack website and API platform with Next.js, ASP.NET Core, PostgreSQL and Docker.',
  },
] as const;

export default function ProjectsScreen() {
  return (
    <ScreenContainer>
      <ScrollView contentContainerStyle={styles.content}>
        <Text style={styles.eyebrow}>PROJECTS</Text>
        <Text style={styles.title}>Selected technical work.</Text>
        <Text style={styles.description}>
          Project data will be loaded from the public backend endpoint in Phase 4.
        </Text>

        {projects.map((item, index) => (
          <AppCard key={item.title} style={styles.card}>
            <Text style={styles.index}>0{index + 1}</Text>
            <Text style={styles.cardTitle}>{item.title}</Text>
            <Text style={styles.cardText}>{item.text}</Text>
          </AppCard>
        ))}
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
  eyebrow: { color: colors.primary, ...typography.label },
  title: { color: colors.text, ...typography.h1 },
  description: { color: colors.textMuted, ...typography.body, marginBottom: spacing.md },
  card: { gap: spacing.sm },
  index: { color: colors.primary, ...typography.label },
  cardTitle: { color: colors.text, ...typography.h2 },
  cardText: { color: colors.textMuted, ...typography.body },
});
'@ | Set-Content "mobile\app\(tabs)\projects.tsx" -Encoding UTF8

@'
import { ScrollView, StyleSheet, Text, View } from 'react-native';

import { AppCard } from '../../src/components/ui/AppCard';
import { ScreenContainer } from '../../src/components/ScreenContainer';
import { colors, spacing, typography } from '../../src/theme';

const systems = [
  { name: 'Backend API', state: 'Prepared', live: true },
  { name: 'PostgreSQL readiness', state: 'Prepared', live: true },
  { name: 'Infrastructure lab', state: 'Demo', live: false },
  { name: 'Security telemetry', state: 'Demo', live: false },
] as const;

export default function InfrastructureScreen() {
  return (
    <ScreenContainer>
      <ScrollView contentContainerStyle={styles.content}>
        <Text style={styles.eyebrow}>INFRASTRUCTURE</Text>
        <Text style={styles.title}>Operational visibility without fake data.</Text>
        <Text style={styles.description}>
          Live backend health will be separated from lab and demo information.
        </Text>

        <AppCard style={styles.card}>
          {systems.map((item, index) => (
            <View
              key={item.name}
              style={[styles.row, index === systems.length - 1 && styles.lastRow]}>
              <View style={styles.left}>
                <View
                  style={[
                    styles.dot,
                    { backgroundColor: item.live ? colors.success : colors.warning },
                  ]}
                />
                <Text style={styles.name}>{item.name}</Text>
              </View>
              <Text style={styles.state}>{item.state}</Text>
            </View>
          ))}
        </AppCard>

        <Text style={styles.note}>
          Phase 5 will connect the real /health/live and /health/ready endpoints.
        </Text>
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
  eyebrow: { color: colors.primary, ...typography.label },
  title: { color: colors.text, ...typography.h1 },
  description: { color: colors.textMuted, ...typography.body, marginBottom: spacing.md },
  card: { paddingVertical: spacing.sm },
  row: {
    minHeight: 58,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    borderBottomWidth: 1,
    borderBottomColor: colors.border,
  },
  lastRow: { borderBottomWidth: 0 },
  left: { flexDirection: 'row', alignItems: 'center', gap: spacing.sm },
  dot: { width: 9, height: 9, borderRadius: 999 },
  name: { color: colors.text, ...typography.bodyStrong },
  state: { color: colors.textMuted, ...typography.small },
  note: { color: colors.textMuted, ...typography.small },
});
'@ | Set-Content "mobile\app\(tabs)\infrastructure.tsx" -Encoding UTF8

@'
import { ScrollView, StyleSheet, Text, TextInput, View } from 'react-native';

import { AppButton } from '../../src/components/ui/AppButton';
import { ScreenContainer } from '../../src/components/ScreenContainer';
import { colors, radius, spacing, typography } from '../../src/theme';

export default function ContactScreen() {
  return (
    <ScreenContainer>
      <ScrollView contentContainerStyle={styles.content} keyboardShouldPersistTaps="handled">
        <Text style={styles.eyebrow}>CONTACT</Text>
        <Text style={styles.title}>Start a conversation.</Text>
        <Text style={styles.description}>
          UI only in Phase 3. Submission will connect to the existing backend in Phase 4.
        </Text>

        <View style={styles.form}>
          <TextInput
            placeholder="Name"
            placeholderTextColor={colors.textMuted}
            style={styles.input}
          />
          <TextInput
            placeholder="Email"
            placeholderTextColor={colors.textMuted}
            keyboardType="email-address"
            autoCapitalize="none"
            style={styles.input}
          />
          <TextInput
            placeholder="Subject"
            placeholderTextColor={colors.textMuted}
            style={styles.input}
          />
          <TextInput
            placeholder="Message"
            placeholderTextColor={colors.textMuted}
            multiline
            textAlignVertical="top"
            style={[styles.input, styles.message]}
          />

          <AppButton>Send message</AppButton>
        </View>
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
  eyebrow: { color: colors.primary, ...typography.label },
  title: { color: colors.text, ...typography.h1 },
  description: { color: colors.textMuted, ...typography.body },
  form: { gap: spacing.md, marginTop: spacing.md },
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
});
'@ | Set-Content "mobile\app\(tabs)\contact.tsx" -Encoding UTF8

Step "Running TypeScript check"
Push-Location "mobile"
try {
  npx tsc --noEmit
  if ($LASTEXITCODE -ne 0) { throw "TypeScript check failed." }
} finally {
  Pop-Location
}

Ok "TypeScript check passed."
Step "Phase 3 completed"
Write-Host ""
Write-Host "Start Expo with:" -ForegroundColor White
Write-Host "  cd mobile" -ForegroundColor Gray
Write-Host "  npx expo start --tunnel" -ForegroundColor Gray
Write-Host ""
Write-Host "You should now see the professional Phase 3 Netsera UI." -ForegroundColor Green
