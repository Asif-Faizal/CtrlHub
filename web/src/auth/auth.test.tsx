import { screen, waitFor, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { Route, Routes } from "react-router";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { api } from "../api/client";
import { tokenStore } from "../api/tokens";
import type { Permission, UserInfo } from "../api/types";
import { App } from "../App";
import { renderWithProviders } from "../test/utils";
import { RequirePermission, RequireRole } from "./guards";

function user(overrides: Partial<UserInfo>): UserInfo {
  return {
    id: "u1",
    name: "Arun Kumar",
    email: "arun@example.com",
    role: "RECEPTIONIST",
    dashboard: "gym",
    tenant_id: "t1",
    tenant_code: "gym_001",
    tenant_name: "Iron House",
    permissions: ["tenant.read", "members.read"],
    ...overrides,
  };
}

function mockGet(routes: Record<string, unknown>) {
  return vi.spyOn(api, "get").mockImplementation(async (url: string) => {
    if (url in routes) return { data: routes[url] };
    throw Object.assign(new Error(`unexpected GET ${url}`), { isAxiosError: false });
  });
}

describe("auth and routing", () => {
  beforeEach(() => {
    tokenStore.clear();
  });
  afterEach(() => {
    vi.restoreAllMocks();
  });

  it("redirects anonymous users to the login page", async () => {
    renderWithProviders(<App />, { route: "/gym/members" });
    expect(await screen.findByRole("heading", { name: "Sign in" })).toBeInTheDocument();
  });

  it("routes a platform admin to the platform dashboard after login", async () => {
    const admin = user({ role: "PLATFORM_ADMIN", dashboard: "platform", tenant_id: undefined, tenant_name: undefined, permissions: ["platform.manage"] });
    vi.spyOn(api, "post").mockResolvedValue({ data: { access_token: "a", refresh_token: "r", token_type: "Bearer", expires_in: 900, user: admin } });
    mockGet({
      "/platform/stats": { total_tenants: 2, active_tenants: 1, total_users: 3, total_members: 4, whatsapp_connected: 0, messages_last_30_days: 0 },
      "/platform/tenants": { items: [], total: 0, page: 1, page_size: 5 },
    });

    renderWithProviders(<App />, { route: "/login" });
    await userEvent.type(screen.getByLabelText("Email"), "admin@ctrlhub.local");
    await userEvent.type(screen.getByLabelText("Password"), "secret-password");
    await userEvent.click(screen.getByRole("button", { name: "Sign in" }));

    expect(await screen.findByRole("heading", { name: "Platform overview" })).toBeInTheDocument();
    expect(tokenStore.access()).toBe("a");
    expect(screen.getByRole("link", { name: "Gyms" })).toBeInTheDocument();
  });

  it("shows the server error message when login fails", async () => {
    vi.spyOn(api, "post").mockRejectedValue(
      Object.assign(new Error("401"), { isAxiosError: true, response: { status: 401, data: { error: { code: "UNAUTHORIZED", message: "invalid email or password" } } } }),
    );
    renderWithProviders(<App />, { route: "/login" });
    await userEvent.type(screen.getByLabelText("Email"), "x@example.com");
    await userEvent.type(screen.getByLabelText("Password"), "wrong");
    await userEvent.click(screen.getByRole("button", { name: "Sign in" }));
    expect(await screen.findByText("invalid email or password")).toBeInTheDocument();
  });

  it("only shows navigation the user's role permits", async () => {
    tokenStore.set("a", "r");
    mockGet({ "/auth/me": user({}) });
    renderWithProviders(<App />, { route: "/gym" });
    const nav = within(await screen.findByRole("navigation"));
    expect(nav.getByRole("link", { name: "Members" })).toBeInTheDocument();
    expect(nav.queryByRole("link", { name: "Users" })).not.toBeInTheDocument();
    expect(nav.queryByRole("link", { name: "Payments" })).not.toBeInTheDocument();
    expect(nav.queryByRole("link", { name: "Automation" })).not.toBeInTheDocument();
  });

  it("sends gym users away from platform routes", async () => {
    tokenStore.set("a", "r");
    mockGet({ "/auth/me": user({}) });
    renderWithProviders(
      <Routes>
        <Route path="/platform" element={<RequireRole dashboard="platform" />}>
          <Route index element={<p>platform area</p>} />
        </Route>
        <Route path="/gym" element={<p>gym area</p>} />
      </Routes>,
      { route: "/platform" },
    );
    expect(await screen.findByText("gym area")).toBeInTheDocument();
  });

  it("blocks pages the user lacks permission for", async () => {
    tokenStore.set("a", "r");
    mockGet({ "/auth/me": user({ permissions: ["members.read"] as Permission[] }) });
    renderWithProviders(
      <RequirePermission perm="payments.read">
        <p>secret payments</p>
      </RequirePermission>,
    );
    await waitFor(() => expect(screen.getByRole("alert")).toHaveTextContent("You do not have permission"));
    expect(screen.queryByText("secret payments")).not.toBeInTheDocument();
  });
});
