import { createContext, useCallback, useContext, useEffect, useMemo, useState, type ReactNode } from "react";
import { useQueryClient } from "@tanstack/react-query";
import { api, setSessionExpiredHandler } from "../api/client";
import { tokenStore } from "../api/tokens";
import type { Permission, Session, UserInfo } from "../api/types";

interface AuthState {
  user: UserInfo | null;
  loading: boolean;
  login: (email: string, password: string) => Promise<UserInfo>;
  logout: () => Promise<void>;
  can: (perm: Permission) => boolean;
}

const AuthContext = createContext<AuthState | null>(null);

export function AuthProvider({ children }: { children: ReactNode }) {
  const queryClient = useQueryClient();
  const [user, setUser] = useState<UserInfo | null>(null);
  const [loading, setLoading] = useState(() => tokenStore.access() !== null);

  const clearSession = useCallback(() => {
    tokenStore.clear();
    setUser(null);
    queryClient.clear();
  }, [queryClient]);

  useEffect(() => {
    setSessionExpiredHandler(clearSession);
    if (!tokenStore.access()) return;
    api
      .get<UserInfo>("/auth/me")
      .then(({ data }) => setUser(data))
      .catch(() => clearSession())
      .finally(() => setLoading(false));
  }, [clearSession]);

  const login = useCallback(async (email: string, password: string) => {
    const { data } = await api.post<Session>("/auth/login", { email, password });
    tokenStore.set(data.access_token, data.refresh_token);
    setUser(data.user);
    return data.user;
  }, []);

  const logout = useCallback(async () => {
    const refresh = tokenStore.refresh();
    try {
      if (refresh) await api.post("/auth/logout", { refresh_token: refresh });
    } finally {
      clearSession();
    }
  }, [clearSession]);

  const value = useMemo<AuthState>(
    () => ({
      user,
      loading,
      login,
      logout,
      can: (perm) => user?.permissions.includes(perm) ?? false,
    }),
    [user, loading, login, logout],
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

// eslint-disable-next-line react-refresh/only-export-components
export function useAuth(): AuthState {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error("useAuth must be used inside AuthProvider");
  return ctx;
}

// eslint-disable-next-line react-refresh/only-export-components
export function homePath(user: UserInfo): string {
  return user.dashboard === "platform" ? "/platform" : "/gym";
}
