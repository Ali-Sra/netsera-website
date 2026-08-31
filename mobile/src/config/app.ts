const rawApiUrl = process.env.EXPO_PUBLIC_API_URL?.trim();

function normalizeBaseUrl(value: string) {
  return value.replace(/\/+$/, '');
}

export const appConfig = {
  apiBaseUrl: normalizeBaseUrl(rawApiUrl || 'http://localhost:8080'),
  requestTimeoutMs: 10000,
  isProductionApi: Boolean(rawApiUrl?.startsWith('https://')),
} as const;
