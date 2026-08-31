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
