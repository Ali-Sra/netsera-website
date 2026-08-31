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
