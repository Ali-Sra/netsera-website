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
