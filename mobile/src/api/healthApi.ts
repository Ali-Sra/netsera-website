import { appConfig } from '../config/app';

export type HealthState = 'healthy' | 'unhealthy' | 'unreachable';

export type HealthCheckResult = {
  state: HealthState;
  status: number | null;
  message: string;
  latencyMs: number | null;
  checkedAt: string;
};

async function checkHealth(path: string): Promise<HealthCheckResult> {
  const controller = new AbortController();
  const startedAt = Date.now();
  const timeout = setTimeout(
    () => controller.abort(),
    appConfig.requestTimeoutMs,
  );

  try {
    const response = await fetch(`${appConfig.apiBaseUrl}${path}`, {
      method: 'GET',
      headers: {
        Accept: 'text/plain, application/json',
      },
      signal: controller.signal,
    });

    const latencyMs = Date.now() - startedAt;
    const body = (await response.text()).trim();

    return {
      state: response.ok ? 'healthy' : 'unhealthy',
      status: response.status,
      message: body || response.statusText || 'No response body',
      latencyMs,
      checkedAt: new Date().toISOString(),
    };
  } catch (error) {
    return {
      state: 'unreachable',
      status: null,
      message:
        error instanceof Error && error.name === 'AbortError'
          ? 'Request timed out'
          : error instanceof Error
            ? error.message
            : 'Network request failed',
      latencyMs: null,
      checkedAt: new Date().toISOString(),
    };
  } finally {
    clearTimeout(timeout);
  }
}

export const healthApi = {
  live: () => checkHealth('/health/live'),
  ready: () => checkHealth('/health/ready'),
};
