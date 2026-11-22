import { useState } from "react";
import { Link, useNavigate } from "react-router";
import { useGet } from "../../api/hooks";
import type { Member, Page } from "../../api/types";
import { Can } from "../../auth/guards";
import { Badge, PageHeader, Pagination, QueryState, Table } from "../../components/ui";
import { formatDate } from "../../lib/format";

export function MembersPage() {
  const navigate = useNavigate();
  const [search, setSearch] = useState("");
  const [status, setStatus] = useState("");
  const [page, setPage] = useState(1);
  const query = useGet<Page<Member>>("/gym/members", { search, status, page, page_size: 20 });

  return (
    <>
      <PageHeader
        title="Members"
        actions={
          <Can perm="members.write">
            <Link to="/gym/members/new" className="rounded-md bg-indigo-600 px-3.5 py-2 text-sm font-medium text-white hover:bg-indigo-700">
              Add member
            </Link>
          </Can>
        }
      />
      <div className="mb-4 flex flex-wrap gap-3">
        <input
          placeholder="Search name, phone or email"
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
          aria-label="Membership filter"
        >
          <option value="">All members</option>
          <option value="active">Active membership</option>
          <option value="expired">Expired membership</option>
          <option value="none">No membership</option>
        </select>
      </div>
      <QueryState query={query} isEmpty={(p) => p.items.length === 0} emptyMessage="No members match these filters.">
        {(p) => (
          <>
            <Table
              rows={p.items}
              rowKey={(m) => m.id}
              onRowClick={(m) => navigate(`/gym/members/${m.id}`)}
              columns={[
                { header: "Name", cell: (m) => <span className="font-medium text-slate-900">{m.full_name}</span> },
                { header: "Phone", cell: (m) => m.phone },
                { header: "Plan", cell: (m) => m.current_plan || "—" },
                { header: "Membership", cell: (m) => <Badge value={m.membership_status} /> },
                { header: "Expires", cell: (m) => formatDate(m.expires_on) },
                { header: "WhatsApp", cell: (m) => (m.whatsapp_opt_in ? "Opted in" : "—") },
              ]}
            />
            <Pagination page={p.page} pageSize={p.page_size} total={p.total} onChange={setPage} />
          </>
        )}
      </QueryState>
    </>
  );
}
