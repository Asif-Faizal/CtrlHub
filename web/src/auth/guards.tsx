import type { ReactNode } from "react";
import { Navigate, Outlet, useLocation } from "react-router";
import type { Permission } from "../api/types";
import { PageState } from "../components/ui";
import { homePath, useAuth } from "./AuthContext";

// These guards only shape navigation. Every permission is enforced again by
// the backend, which is the source of truth.

export function RequireAuth() {
  const { user, loading } = useAuth();
  const location = useLocation();
  if (loading) return <PageState state="loading" />;
  if (!user) return <Navigate to="/login" replace state={{ from: location.pathname }} />;
  return <Outlet />;
}

export function RequireRole({ dashboard }: { dashboard: "platform" | "gym" }) {
  const { user, loading } = useAuth();
  if (loading) return <PageState state="loading" />;
  if (!user) return <Navigate to="/login" replace />;
  if (user.dashboard !== dashboard) return <Navigate to={homePath(user)} replace />;
  return <Outlet />;
}

export function RequirePermission({ perm, children }: { perm: Permission; children: ReactNode }) {
  const { can } = useAuth();
  if (!can(perm)) {
    return <PageState state="error" message="You do not have permission to view this page." />;
  }
  return <>{children}</>;
}

export function Can({ perm, children }: { perm: Permission; children: ReactNode }) {
  const { can } = useAuth();
  return can(perm) ? <>{children}</> : null;
}
