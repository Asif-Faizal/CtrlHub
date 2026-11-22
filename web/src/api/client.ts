import axios, { AxiosError, type InternalAxiosRequestConfig } from "axios";
import type { ApiErrorBody, Session } from "./types";
import { tokenStore } from "./tokens";

export const api = axios.create({ baseURL: "/api/v1", timeout: 30_000 });

type RetriableConfig = InternalAxiosRequestConfig & { _retried?: boolean };

let refreshing: Promise<string | null> | null = null;
let onSessionExpired: () => void = () => {};

export function setSessionExpiredHandler(fn: () => void) {
  onSessionExpired = fn;
}

// refreshTokens performs a single refresh even when many requests fail with
// 401 at once; all of them wait for the same promise.
export function refreshTokens(): Promise<string | null> {
  if (!refreshing) {
    const token = tokenStore.refresh();
    refreshing = (
      token
        ? axios
            .post<Session>("/api/v1/auth/refresh", { refresh_token: token })
            .then(({ data }) => {
              tokenStore.set(data.access_token, data.refresh_token);
              return data.access_token;
            })
            .catch(() => {
              tokenStore.clear();
              return null;
            })
        : Promise.resolve(null)
    ).finally(() => {
      refreshing = null;
    });
  }
  return refreshing;
}

api.interceptors.request.use((config) => {
  const token = tokenStore.access();
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});

api.interceptors.response.use(
  (res) => res,
  async (error: AxiosError<ApiErrorBody>) => {
    const config = error.config as RetriableConfig | undefined;
    const isAuthCall = config?.url?.startsWith("/auth/");
    if (error.response?.status === 401 && config && !config._retried && !isAuthCall) {
      config._retried = true;
      const token = await refreshTokens();
      if (token) {
        config.headers.Authorization = `Bearer ${token}`;
        return api(config);
      }
      onSessionExpired();
    }
    return Promise.reject(error);
  },
);

export function errorMessage(err: unknown): string {
  if (axios.isAxiosError(err)) {
    const body = err.response?.data as ApiErrorBody | undefined;
    if (body?.error?.message) {
      const details = body.error.details;
      if (details && Object.keys(details).length > 0) {
        return `${body.error.message}: ${Object.entries(details)
          .map(([k, v]) => `${k} ${v}`)
          .join(", ")}`;
      }
      return body.error.message;
    }
    if (!err.response) return "Cannot reach the server. Check your connection.";
    return `Request failed (${err.response.status})`;
  }
  return err instanceof Error ? err.message : "Something went wrong";
}

export function fieldErrors(err: unknown): Record<string, string> {
  if (axios.isAxiosError(err)) {
    return (err.response?.data as ApiErrorBody | undefined)?.error?.details ?? {};
  }
  return {};
}
