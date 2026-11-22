import { Link } from "react-router";
import { useGet } from "../../api/hooks";
import type { Page, PlatformStats, TenantSummary } from "../../api/types";
import { Badge, Card, PageHeader, QueryState, Stat, Table } from "../../components/ui";
import { formatDate } from "../../lib/format";

export function PlatformOverviewPage() {
  const stats = useGet<PlatformStats>("/platform/stats");
  const recent = useGet<Page<TenantSummary>>("/platform/tenants", { page: 1, page_size: 5 });

  return (
    <>
      <PageHeader
        title="Platform overview"
        actions={
          <Link to="/platform/gyms/new" className="rounded-md bg-indigo-600 px-3.5 py-2 text-sm font-medium text-white hover:bg-indigo-700">
            Add gym
          </Link>
        }
      />
      <QueryState query={stats}>
        {(s) => (
          <div className="grid grid-cols-2 gap-4 lg:grid-cols-3">
            <Stat label="Gyms" value={s.total_tenants} hint={`${s.active_tenants} active`} />
            <Stat label="Gym users" value={s.total_users} />
            <Stat label="Members" value={s.total_members} />
            <Stat label="WhatsApp connected" value={s.whatsapp_connected} />
            <Stat label="Messages (30 days)" value={s.messages_last_30_days} />
          </div>
        )}
      </QueryState>
      <Card title="Recently added gyms" className="mt-6">
        <QueryState query={recent} isEmpty={(p) => p.items.length === 0} emptyMessage="No gyms onboarded yet.">
          {(p) => (
            <Table
              rows={p.items}
              rowKey={(t) => t.id}
              columns={[
                { header: "Code", cell: (t) => <Link className="font-mono text-indigo-600" to={`/platform/gyms/${t.id}`}>{t.code}</Link> },
                { header: "Name", cell: (t) => t.name },
                { header: "Status", cell: (t) => <Badge value={t.status} /> },
                { header: "Created", cell: (t) => formatDate(t.created_at) },
              ]}
            />
          )}
        </QueryState>
      </Card>
    </>
  );
}
