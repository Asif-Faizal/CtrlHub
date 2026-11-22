import { useState } from "react";
import { NavLink, Outlet, useNavigate } from "react-router";
import type { Permission } from "../api/types";
import { useAuth } from "../auth/AuthContext";
import { humanize } from "../lib/format";

interface NavItem {
  to: string;
  label: string;
  perm?: Permission;
  end?: boolean;
}

const platformNav: NavItem[] = [
  { to: "/platform", label: "Overview", end: true },
  { to: "/platform/gyms", label: "Gyms" },
  { to: "/platform/whatsapp", label: "WhatsApp status" },
];

const gymNav: NavItem[] = [
  { to: "/gym", label: "Overview", end: true, perm: "tenant.read" },
  { to: "/gym/members", label: "Members", perm: "members.read" },
  { to: "/gym/plans", label: "Membership plans", perm: "plans.read" },
  { to: "/gym/renewals", label: "Renewals", perm: "memberships.read" },
  { to: "/gym/payments", label: "Payments", perm: "payments.read" },
  { to: "/gym/attendance", label: "Attendance", perm: "attendance.read" },
  { to: "/gym/holidays", label: "Holidays", perm: "holidays.read" },
  { to: "/gym/leads", label: "Leads", perm: "leads.read" },
  { to: "/gym/promotions", label: "Promotions", perm: "campaigns.read" },
  { to: "/gym/whatsapp", label: "WhatsApp", perm: "whatsapp.read" },
  { to: "/gym/automation", label: "Automation", perm: "automation.manage" },
  { to: "/gym/messages", label: "Message history", perm: "messages.read" },
  { to: "/gym/users", label: "Users", perm: "users.manage" },
  { to: "/gym/settings", label: "Gym settings", perm: "tenant.read" },
];

export function AppLayout({ area }: { area: "platform" | "gym" }) {
  const { user, can, logout } = useAuth();
  const navigate = useNavigate();
  const [open, setOpen] = useState(false);
  const items = (area === "platform" ? platformNav : gymNav).filter((i) => !i.perm || can(i.perm));

  const onLogout = async () => {
    await logout();
    navigate("/login", { replace: true });
  };

  return (
    <div className="min-h-screen lg:flex">
      <aside className={`${open ? "block" : "hidden"} border-r border-slate-200 bg-white lg:block lg:w-60 lg:shrink-0`}>
        <div className="px-5 py-4">
          <p className="text-lg font-bold text-indigo-600">CtrlHub</p>
          <p className="truncate text-xs text-slate-500">
            {area === "platform" ? "Platform administration" : `${user?.tenant_name} · ${user?.tenant_code}`}
          </p>
        </div>
        <nav className="space-y-0.5 px-3 pb-6">
          {items.map((i) => (
            <NavLink
              key={i.to}
              to={i.to}
              end={i.end}
              onClick={() => setOpen(false)}
              className={({ isActive }) =>
                `block rounded-md px-3 py-2 text-sm ${isActive ? "bg-indigo-50 font-medium text-indigo-700" : "text-slate-600 hover:bg-slate-100"}`
              }
            >
              {i.label}
            </NavLink>
          ))}
        </nav>
      </aside>
      <div className="flex min-w-0 flex-1 flex-col">
        <header className="flex items-center justify-between gap-3 border-b border-slate-200 bg-white px-4 py-3 lg:px-8">
          <button className="rounded-md px-2 py-1 text-sm ring-1 ring-slate-300 lg:hidden" onClick={() => setOpen((v) => !v)}>
            Menu
          </button>
          <div className="ml-auto flex items-center gap-4 text-sm">
            <span className="hidden text-slate-600 sm:inline">
              {user?.name} · <span className="text-slate-400">{user && humanize(user.role)}</span>
            </span>
            <NavLink to="/account" className="text-slate-600 hover:text-slate-900">
              Account
            </NavLink>
            <button onClick={onLogout} className="font-medium text-rose-600 hover:text-rose-700">
              Log out
            </button>
          </div>
        </header>
        <main className="mx-auto w-full max-w-6xl flex-1 px-4 py-6 lg:px-8">
          <Outlet />
        </main>
      </div>
    </div>
  );
}
