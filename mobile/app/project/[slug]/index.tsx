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
