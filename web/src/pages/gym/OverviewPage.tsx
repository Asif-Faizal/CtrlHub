import { Link } from "react-router";
import { useGet } from "../../api/hooks";
import type { DailyReport, Membership, Page, WhatsAppStatusResponse } from "../../api/types";
import { useAuth } from "../../auth/AuthContext";
import { Badge, Card, PageHeader, QueryState, Stat, Table } from "../../components/ui";
import { formatDate, formatMoney } from "../../lib/format";

export function GymOverviewPage() {
  const { user, can } = useAuth();
  return (
    <>
      <PageHeader title={`Welcome, ${user?.name.split(" ")[0]}`} subtitle={`${user?.tenant_name} · ${user?.tenant_code}`} />
      {can("reports.read") && <TodayReport />}
      <div className="mt-6 grid gap-6 lg:grid-cols-3">
        {can("memberships.read") && (
          <Card title="Expiring in the next 7 days" className="lg:col-span-2" actions={<Link to="/gym/renewals" className="text-sm text-indigo-600">View all</Link>}>
            <ExpiringSoon />
          </Card>
        )}
        {can("whatsapp.read") && (
          <Card title="WhatsApp" actions={<Link to="/gym/whatsapp" className="text-sm text-indigo-600">Manage</Link>}>
            <WhatsAppSummary />
          </Card>
        )}
      </div>
      {!can("reports.read") && !can("memberships.read") && (
        <Card title="Quick links" className="mt-6">
          <div className="flex gap-4 text-sm">
            {can("attendance.write") && <Link className="text-indigo-600" to="/gym/attendance">Record attendance</Link>}
            {can("members.read") && <Link className="text-indigo-600" to="/gym/members">Members</Link>}
            {can("holidays.read") && <Link className="text-indigo-600" to="/gym/holidays">Holidays</Link>}
          </div>
        </Card>
      )}
    </>
  );
}

function TodayReport() {
  const query = useGet<DailyReport>("/gym/reports/daily");
  return (
    <QueryState query={query}>
      {(r) => (
        <div className="grid grid-cols-2 gap-4 lg:grid-cols-4">
          <Stat label="Active members" value={r.active_members} />
          <Stat label="Check-ins today" value={r.attendance} />
          <Stat label="Revenue today" value={formatMoney(r.revenue_minor)} />
          <Stat label="Pending payments" value={formatMoney(r.pending_payments_minor)} />
          <Stat label="New members today" value={r.new_members} />
          <Stat label="Renewals today" value={r.renewals} />
          <Stat label="Expiring in 7 days" value={r.expiring_next_7_days} />
          <Stat label="Expired today" value={r.expired_today} />
        </div>
      )}
    </QueryState>
  );
}

function ExpiringSoon() {
  const query = useGet<Page<Membership>>("/gym/memberships", { view: "expiring", days: 7, page_size: 10 });
  return (
    <QueryState query={query} isEmpty={(p) => p.items.length === 0} emptyMessage="No memberships expire in the next 7 days.">
      {(p) => (
        <Table
          rows={p.items}
          rowKey={(m) => m.id}
          columns={[
            { header: "Member", cell: (m) => <Link className="text-indigo-600" to={`/gym/members/${m.member_id}`}>{m.member_name}</Link> },
            { header: "Plan", cell: (m) => m.plan_name },
            { header: "Expires", cell: (m) => formatDate(m.end_date) },
            { header: "Payment", cell: (m) => <Badge value={m.payment_status} /> },
          ]}
        />
      )}
    </QueryState>
  );
}

function WhatsAppSummary() {
  const query = useGet<WhatsAppStatusResponse>("/gym/whatsapp");
  return (
    <QueryState query={query}>
      {(w) => (
        <div className="space-y-2 text-sm">
          <Badge value={w.session.status} />
          <p className="text-slate-600">Session {w.session.session_name}</p>
          {w.provider === "mock" && <p className="text-xs text-amber-700">Mock provider: no real WhatsApp messages are sent.</p>}
        </div>
      )}
    </QueryState>
  );
}
