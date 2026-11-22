import { Navigate, Route, Routes } from "react-router";
import { homePath, useAuth } from "./auth/AuthContext";
import { RequireAuth, RequirePermission, RequireRole } from "./auth/guards";
import { AppLayout } from "./layouts/AppLayout";
import { PageState } from "./components/ui";
import { LoginPage } from "./pages/auth/LoginPage";
import { SetupPasswordPage } from "./pages/auth/SetupPasswordPage";
import { AccountPage } from "./pages/auth/AccountPage";
import { PlatformOverviewPage } from "./pages/platform/OverviewPage";
import { GymListPage } from "./pages/platform/GymListPage";
import { GymFormPage } from "./pages/platform/GymFormPage";
import { GymDetailPage } from "./pages/platform/GymDetailPage";
import { WhatsAppSessionsPage } from "./pages/platform/WhatsAppSessionsPage";
import { GymOverviewPage } from "./pages/gym/OverviewPage";
import { MembersPage } from "./pages/gym/MembersPage";
import { MemberFormPage } from "./pages/gym/MemberFormPage";
import { MemberProfilePage } from "./pages/gym/MemberProfilePage";
import { PlansPage } from "./pages/gym/PlansPage";
import { RenewalsPage } from "./pages/gym/RenewalsPage";
import { PaymentsPage } from "./pages/gym/PaymentsPage";
import { AttendancePage } from "./pages/gym/AttendancePage";
import { HolidaysPage } from "./pages/gym/HolidaysPage";
import { LeadsPage } from "./pages/gym/LeadsPage";
import { PromotionsPage } from "./pages/gym/PromotionsPage";
import { PromotionDetailPage } from "./pages/gym/PromotionDetailPage";
import { WhatsAppPage } from "./pages/gym/WhatsAppPage";
import { AutomationPage } from "./pages/gym/AutomationPage";
import { MessagesPage } from "./pages/gym/MessagesPage";
import { UsersPage } from "./pages/gym/UsersPage";
import { GymSettingsPage } from "./pages/gym/GymSettingsPage";
import type { Permission } from "./api/types";
import type { ReactNode } from "react";

function Home() {
  const { user } = useAuth();
  return <Navigate to={user ? homePath(user) : "/login"} replace />;
}

function AccountShell() {
  const { user } = useAuth();
  return <AppLayout area={user?.dashboard ?? "gym"} />;
}

const guard = (perm: Permission, el: ReactNode) => <RequirePermission perm={perm}>{el}</RequirePermission>;

export function App() {
  return (
    <Routes>
      <Route path="/login" element={<LoginPage />} />
      <Route path="/setup-password" element={<SetupPasswordPage />} />
      <Route element={<RequireAuth />}>
        <Route index element={<Home />} />
        <Route element={<AccountShell />}>
          <Route path="/account" element={<AccountPage />} />
        </Route>
        <Route path="/platform" element={<RequireRole dashboard="platform" />}>
          <Route element={<AppLayout area="platform" />}>
            <Route index element={<PlatformOverviewPage />} />
            <Route path="gyms" element={<GymListPage />} />
            <Route path="gyms/new" element={<GymFormPage />} />
            <Route path="gyms/:id" element={<GymDetailPage />} />
            <Route path="gyms/:id/edit" element={<GymFormPage />} />
            <Route path="whatsapp" element={<WhatsAppSessionsPage />} />
          </Route>
        </Route>
        <Route path="/gym" element={<RequireRole dashboard="gym" />}>
          <Route element={<AppLayout area="gym" />}>
            <Route index element={guard("tenant.read", <GymOverviewPage />)} />
            <Route path="members" element={guard("members.read", <MembersPage />)} />
            <Route path="members/new" element={guard("members.write", <MemberFormPage />)} />
            <Route path="members/:id" element={guard("members.read", <MemberProfilePage />)} />
            <Route path="members/:id/edit" element={guard("members.write", <MemberFormPage />)} />
            <Route path="plans" element={guard("plans.read", <PlansPage />)} />
            <Route path="renewals" element={guard("memberships.read", <RenewalsPage />)} />
            <Route path="payments" element={guard("payments.read", <PaymentsPage />)} />
            <Route path="attendance" element={guard("attendance.read", <AttendancePage />)} />
            <Route path="holidays" element={guard("holidays.read", <HolidaysPage />)} />
            <Route path="leads" element={guard("leads.read", <LeadsPage />)} />
            <Route path="promotions" element={guard("campaigns.read", <PromotionsPage />)} />
            <Route path="promotions/:id" element={guard("campaigns.read", <PromotionDetailPage />)} />
            <Route path="whatsapp" element={guard("whatsapp.read", <WhatsAppPage />)} />
            <Route path="automation" element={guard("automation.manage", <AutomationPage />)} />
            <Route path="messages" element={guard("messages.read", <MessagesPage />)} />
            <Route path="users" element={guard("users.manage", <UsersPage />)} />
            <Route path="settings" element={guard("tenant.read", <GymSettingsPage />)} />
          </Route>
        </Route>
      </Route>
      <Route path="*" element={<div className="p-10"><PageState state="empty" message="Page not found." /></div>} />
    </Routes>
  );
}
