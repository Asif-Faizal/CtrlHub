import { Link } from "react-router";
import { useGet } from "../../api/hooks";
import type { WhatsAppSession } from "../../api/types";
import { Badge, PageHeader, QueryState, Table } from "../../components/ui";
import { formatDateTime } from "../../lib/format";

export function WhatsAppSessionsPage() {
  const query = useGet<WhatsAppSession[]>("/platform/whatsapp-sessions");
  return (
    <>
      <PageHeader title="WhatsApp connection status" subtitle="One WhatsApp session per gym, named after the tenant code." />
      <QueryState query={query} isEmpty={(l) => (l ?? []).length === 0} emptyMessage="No gyms onboarded yet.">
        {(list) => (
          <Table
            rows={list}
            rowKey={(s) => s.tenant_id}
            columns={[
              { header: "Gym", cell: (s) => <Link className="text-indigo-600" to={`/platform/gyms/${s.tenant_id}`}>{s.tenant_name || s.tenant_id}</Link> },
              { header: "Session", cell: (s) => <span className="font-mono">{s.session_name}</span> },
              { header: "Status", cell: (s) => <Badge value={s.status} /> },
              { header: "Phone", cell: (s) => s.phone_number || "—" },
              { header: "Last checked", cell: (s) => formatDateTime(s.last_status_at) },
            ]}
          />
        )}
      </QueryState>
    </>
  );
}
