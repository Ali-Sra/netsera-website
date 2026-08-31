$ErrorActionPreference = "Stop"

Write-Host "==> Netsera Mobile - Phase 4 Contact + Keyboard Fix" -ForegroundColor Cyan

if (-not (Test-Path ".\mobile\package.json")) {
    throw "Run this script from the netsera-website repository root."
}

$contactPath = ".\mobile\app\(tabs)\contact.tsx"

Write-Host "==> Replacing Contact screen with the real Phase 4 API form" -ForegroundColor Yellow

$contactContent = @'
import { useState } from 'react';
import {
  ActivityIndicator,
  Alert,
  Keyboard,
  KeyboardAvoidingView,
  Platform,
  Pressable,
  ScrollView,
  StyleSheet,
  Text,
  TextInput,
  View,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { ApiError } from '../../src/api/client';
import { publicApi } from '../../src/api/publicApi';
import { colors, radius, spacing } from '../../src/theme';

export default function ContactScreen() {
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [subject, setSubject] = useState('');
  const [message, setMessage] = useState('');
  const [submitting, setSubmitting] = useState(false);

  const validate = () => {
    const cleanName = name.trim();
    const cleanEmail = email.trim();
    const cleanSubject = subject.trim();
    const cleanMessage = message.trim();

    if (cleanName.length < 2) {
      Alert.alert('Check your name', 'Please enter at least 2 characters.');
      return null;
    }

    if (cleanName.length > 120) {
      Alert.alert('Name is too long', 'Please keep your name under 120 characters.');
      return null;
    }

    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(cleanEmail)) {
      Alert.alert('Check your email', 'Please enter a valid email address.');
      return null;
    }

    if (cleanEmail.length > 254) {
      Alert.alert('Email is too long', 'Please keep your email under 254 characters.');
      return null;
    }

    if (cleanSubject.length > 160) {
      Alert.alert('Subject is too long', 'Please keep the subject under 160 characters.');
      return null;
    }

    if (cleanMessage.length < 10) {
      Alert.alert('Message is too short', 'Please enter at least 10 characters.');
      return null;
    }

    if (cleanMessage.length > 5000) {
      Alert.alert('Message is too long', 'Please keep your message under 5000 characters.');
      return null;
    }

    return {
      name: cleanName,
      email: cleanEmail,
      subject: cleanSubject || undefined,
      message: cleanMessage,
    };
  };

  const submit = async () => {
    if (submitting) return;

    const payload = validate();
    if (!payload) return;

    Keyboard.dismiss();
    setSubmitting(true);

    try {
      await publicApi.sendContact(payload);

      setName('');
      setEmail('');
      setSubject('');
      setMessage('');

      Alert.alert(
        'Message sent',
        'Your message was submitted successfully to the Netsera backend.',
      );
    } catch (error) {
      if (error instanceof ApiError && error.status === 429) {
        Alert.alert(
          'Please try again later',
          'Too many contact requests were sent in a short period of time.',
        );
        return;
      }

      Alert.alert(
        'Could not send message',
        error instanceof Error ? error.message : 'Unknown network error.',
      );
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <SafeAreaView style={styles.safeArea} edges={['top']}>
      <KeyboardAvoidingView
        style={styles.flex}
        behavior={Platform.OS === 'ios' ? 'padding' : undefined}
        keyboardVerticalOffset={Platform.OS === 'ios' ? 8 : 0}
      >
        <ScrollView
          style={styles.flex}
          contentContainerStyle={styles.content}
          keyboardShouldPersistTaps="handled"
          keyboardDismissMode={Platform.OS === 'ios' ? 'interactive' : 'on-drag'}
          showsVerticalScrollIndicator={false}
        >
          <Text style={styles.eyebrow}>CONTACT</Text>
          <Text style={styles.title}>Start a conversation.</Text>
          <Text style={styles.subtitle}>
            Connected to the Netsera backend. Send a message directly from the mobile app.
          </Text>

          <View style={styles.form}>
            <Field
              label="Name"
              value={name}
              onChangeText={setName}
              placeholder="Your name"
              autoCapitalize="words"
              maxLength={120}
            />

            <Field
              label="Email"
              value={email}
              onChangeText={setEmail}
              placeholder="you@example.com"
              keyboardType="email-address"
              autoCapitalize="none"
              autoCorrect={false}
              maxLength={254}
            />

            <Field
              label="Subject"
              value={subject}
              onChangeText={setSubject}
              placeholder="Optional"
              maxLength={160}
            />

            <View style={styles.fieldGroup}>
              <Text style={styles.label}>Message</Text>
              <TextInput
                value={message}
                onChangeText={setMessage}
                placeholder="How can Netsera help?"
                placeholderTextColor={colors.textMuted}
                style={[styles.input, styles.messageInput]}
                multiline
                textAlignVertical="top"
                maxLength={5000}
                returnKeyType="default"
              />
              <Text style={styles.counter}>{message.length}/5000</Text>
            </View>

            <Pressable
              onPress={submit}
              disabled={submitting}
              style={({ pressed }) => [
                styles.button,
                pressed && !submitting && styles.buttonPressed,
                submitting && styles.buttonDisabled,
              ]}
            >
              {submitting ? (
                <ActivityIndicator color={colors.background} />
              ) : (
                <Text style={styles.buttonText}>Send message</Text>
              )}
            </Pressable>

            <Text style={styles.note}>
              The backend applies validation and rate limiting to contact submissions.
            </Text>
          </View>
        </ScrollView>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
}

type FieldProps = {
  label: string;
  value: string;
  onChangeText: (value: string) => void;
  placeholder: string;
  keyboardType?: 'default' | 'email-address';
  autoCapitalize?: 'none' | 'sentences' | 'words' | 'characters';
  autoCorrect?: boolean;
  maxLength?: number;
};

function Field({
  label,
  value,
  onChangeText,
  placeholder,
  keyboardType = 'default',
  autoCapitalize = 'sentences',
  autoCorrect = true,
  maxLength,
}: FieldProps) {
  return (
    <View style={styles.fieldGroup}>
      <Text style={styles.label}>{label}</Text>
      <TextInput
        value={value}
        onChangeText={onChangeText}
        placeholder={placeholder}
        placeholderTextColor={colors.textMuted}
        style={styles.input}
        keyboardType={keyboardType}
        autoCapitalize={autoCapitalize}
        autoCorrect={autoCorrect}
        maxLength={maxLength}
        returnKeyType="next"
      />
    </View>
  );
}

const styles = StyleSheet.create({
  flex: {
    flex: 1,
  },
  safeArea: {
    flex: 1,
    backgroundColor: colors.background,
  },
  content: {
    paddingHorizontal: spacing.xl,
    paddingTop: spacing.lg,
    paddingBottom: 180,
  },
  eyebrow: {
    color: colors.accent,
    fontSize: 16,
    fontWeight: '800',
    letterSpacing: 3,
    marginBottom: spacing.lg,
  },
  title: {
    color: colors.text,
    fontSize: 44,
    lineHeight: 50,
    fontWeight: '800',
    letterSpacing: -1.2,
  },
  subtitle: {
    color: colors.textMuted,
    fontSize: 18,
    lineHeight: 28,
    marginTop: spacing.lg,
    marginBottom: spacing.xl,
  },
  form: {
    gap: spacing.lg,
  },
  fieldGroup: {
    gap: 8,
  },
  label: {
    color: colors.text,
    fontSize: 14,
    fontWeight: '700',
  },
  input: {
    minHeight: 58,
    borderWidth: 1,
    borderColor: colors.border,
    borderRadius: radius.lg,
    backgroundColor: colors.surface,
    color: colors.text,
    fontSize: 17,
    paddingHorizontal: spacing.lg,
    paddingVertical: 14,
  },
  messageInput: {
    minHeight: 180,
  },
  counter: {
    color: colors.textMuted,
    fontSize: 12,
    textAlign: 'right',
  },
  button: {
    minHeight: 58,
    borderRadius: radius.lg,
    backgroundColor: colors.accent,
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: spacing.lg,
    marginTop: spacing.sm,
  },
  buttonPressed: {
    opacity: 0.84,
  },
  buttonDisabled: {
    opacity: 0.6,
  },
  buttonText: {
    color: colors.background,
    fontSize: 16,
    fontWeight: '800',
  },
  note: {
    color: colors.textMuted,
    fontSize: 13,
    lineHeight: 20,
    marginBottom: spacing.xl,
  },
});
'@

Set-Content -LiteralPath $contactPath -Value $contactContent -Encoding UTF8

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
Write-Host "==> Fix completed successfully" -ForegroundColor Green
Write-Host ""
Write-Host "This fixes BOTH issues:" -ForegroundColor Cyan
Write-Host "  1. Contact is now the real Phase 4 backend form."
Write-Host "  2. KeyboardAvoidingView + ScrollView keep Send message reachable on iPhone."
Write-Host ""
Write-Host "IMPORTANT: restart Expo with cache cleared so the old Phase 3 screen is not reused:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  cd mobile"
Write-Host "  npx expo start --tunnel -c"
Write-Host ""
Write-Host "Then reopen the project in Expo Go." -ForegroundColor Yellow
