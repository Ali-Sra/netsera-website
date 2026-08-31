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
