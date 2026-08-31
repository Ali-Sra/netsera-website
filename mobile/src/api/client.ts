import { appConfig } from '../config/app';

export class ApiError extends Error {
  status?: number;

  constructor(message: string, status?: number) {
    super(message);
    this.name = 'ApiError';
    this.status = status;
  }
}

type RequestOptions = RequestInit & {
  timeoutMs?: number;
};

export async function apiFetch<T>(
  path: string,
  options: RequestOptions = {},
): Promise<T> {
  const controller = new AbortController();
  const timeoutMs = options.timeoutMs ?? appConfig.requestTimeoutMs;

  const timeout = setTimeout(() => controller.abort(), timeoutMs);

  try {
    const response = await fetch(`${appConfig.apiBaseUrl}${path}`, {
      ...options,
      headers: {
        Accept: 'application/json',
        'Content-Type': 'application/json',
        ...options.headers,
      },
      signal: controller.signal,
    });

    if (!response.ok) {
      let message = `Request failed with status ${response.status}`;

      try {
        const body = await response.json();
        if (typeof body?.message === 'string') {
          message = body.message;
        } else if (typeof body?.title === 'string') {
          message = body.title;
        }
      } catch {
        // Ignore invalid/non-JSON error bodies.
      }

      throw new ApiError(message, response.status);
    }

    if (response.status === 204) {
      return undefined as T;
    }

    return (await response.json()) as T;
  } catch (error) {
    if (error instanceof ApiError) {
      throw error;
    }

    if (error instanceof Error && error.name === 'AbortError') {
      throw new ApiError('The request timed out.');
    }

    throw new ApiError(
      error instanceof Error ? error.message : 'Unknown network error',
    );
  } finally {
    clearTimeout(timeout);
  }
}
