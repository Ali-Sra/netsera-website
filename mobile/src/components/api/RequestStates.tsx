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
