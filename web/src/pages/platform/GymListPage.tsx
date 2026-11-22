import { useState } from "react";
import { Link, useNavigate } from "react-router";
import { useGet } from "../../api/hooks";
import type { Page, TenantSummary } from "../../api/types";
import { Badge, PageHeader, Pagination, QueryState, Table } from "../../components/ui";

export function GymListPage() {
  const navigate = useNavigate();
  const [search, setSearch] = useState("");
  const [status, setStatus] = useState("");
  const [page, setPage] = useState(1);
  const query = useGet<Page<TenantSummary>>("/platform/tenants", { search, status, page, page_size: 20 });

  return (
    <>
      <PageHeader
        title="Gyms"
        subtitle="Every gym is an isolated tenant with its own users, members and WhatsApp session."
        actions={
          <Link to="/platform/gyms/new" className="rounded-md bg-indigo-600 px-3.5 py-2 text-sm font-medium text-white hover:bg-indigo-700">
            Add gym
          </Link>
        }
      />
      <div className="mb-4 flex flex-wrap gap-3">
        <input
          placeholder="Search by name, code or email"
          value={search}
          onChange={(e) => {
            setSearch(e.target.value);
            setPage(1);
          }}
          className="w-72 rounded-md border border-slate-300 px-3 py-2 text-sm"
        />
        <select
          value={status}
          onChange={(e) => {
            setStatus(e.target.value);
            setPage(1);
          }}
          className="rounded-md border border-slate-300 px-3 py-2 text-sm"
        >
          <option value="">All statuses</option>
          <option value="ACTIVE">Active</option>
          <option value="INACTIVE">Inactive</option>
        </select>
      </div>
      <QueryState query={query} isEmpty={(p) => p.items.length === 0} emptyMessage="No gyms match these filters.">
        {(p) => (
          <>
            <Table
              rows={p.items}
              rowKey={(t) => t.id}
              onRowClick={(t) => navigate(`/platform/gyms/${t.id}`)}
              columns={[
                { header: "Code", cell: (t) => <span className="font-mono">{t.code}</span> },
                { header: "Name", cell: (t) => <span className="font-medium text-slate-900">{t.name}</span> },
                { header: "Owner", cell: (t) => t.owner_name },
                { header: "City", cell: (t) => t.city || "—" },
                { header: "Users", cell: (t) => `${t.user_count}/${t.max_users}` },
                { header: "Members", cell: (t) => t.member_count },
                { header: "WhatsApp", cell: (t) => <Badge value={t.whatsapp_status} /> },
                { header: "Status", cell: (t) => <Badge value={t.status} /> },
              ]}
            />
            <Pagination page={p.page} pageSize={p.page_size} total={p.total} onChange={setPage} />
          </>
        )}
      </QueryState>
    </>
  );
}
