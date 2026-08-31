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
