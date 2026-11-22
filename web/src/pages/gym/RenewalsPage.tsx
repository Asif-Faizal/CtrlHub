import { useState } from "react";
import { Link } from "react-router";
import { api, errorMessage } from "../../api/client";
import { useGet, useInvalidate } from "../../api/hooks";
import type { Membership, Page } from "../../api/types";
import { useAuth } from "../../auth/AuthContext";
import { Badge, Button, FormError, PageHeader, Pagination, QueryState, Table } from "../../components/ui";
import { RenewMembershipModal } from "../../components/MembershipModals";
import { formatDate, formatMoney } from "../../lib/format";

const views = [
  { value: "expiring", label: "Expiring soon" },
  { value: "expired", label: "Expired" },
  { value: "active", label: "Active" },
  { value: "all", label: "All" },
];

export function RenewalsPage() {
  const { can } = useAuth();
  const invalidate = useInvalidate();
  const [view, setView] = useState("expiring");
  const [days, setDays] = useState(7);
  const [page, setPage] = useState(1);
  const [renewing, setRenewing] = useState<Membership | null>(null);
  const [error, setError] = useState<string | null>(null);
  const query = useGet<Page<Membership>>("/gym/memberships", { view, days: view === "expiring" ? days : undefined, page, page_size: 20 });

  const cancel = async (m: Membership) => {
    if (!window.confirm(`Cancel ${m.member_name}'s ${m.plan_name} membership? This cannot be undone.`)) return;
    setError(null);
    try {
      await api.post(`/gym/memberships/${m.id}/cancel`);
      await invalidate("/gym/memberships", "/gym/members", "/gym/reports");
    } catch (err) {
      setError(errorMessage(err));
    }
  };

  return (
    <>
      <PageHeader title="Membership renewals" subtitle="Renewals create a new membership; history is never overwritten." />
      <div className="mb-4 flex flex-wrap items-center gap-2">
        {views.map((v) => (
          <button
            key={v.value}
            onClick={() => {
              setView(v.value);
              setPage(1);
            }}
            className={`rounded-full px-3 py-1 text-sm ring-1 ${view === v.value ? "bg-indigo-600 text-white ring-indigo-600" : "bg-white text-slate-600 ring-slate-300"}`}
          >
            {v.label}
          </button>
        ))}
        {view === "expiring" && (
          <select value={days} onChange={(e) => setDays(Number(e.target.value))} className="ml-2 rounded-md border border-slate-300 px-2 py-1 text-sm" aria-label="Within days">
            {[3, 7, 15, 30].map((d) => (
              <option key={d} value={d}>
                within {d} days
              </option>
            ))}
          </select>
        )}
      </div>
      <FormError message={error} />
      <QueryState query={query} isEmpty={(p) => p.items.length === 0} emptyMessage="No memberships in this view.">
        {(p) => (
          <>
            <Table
              rows={p.items}
              rowKey={(m) => m.id}
              columns={[
                { header: "Member", cell: (m) => <Link className="text-indigo-600" to={`/gym/members/${m.member_id}`}>{m.member_name}</Link> },
                { header: "Plan", cell: (m) => m.plan_name },
                { header: "Start", cell: (m) => formatDate(m.start_date) },
                { header: "End", cell: (m) => formatDate(m.end_date) },
                { header: "Status", cell: (m) => <Badge value={m.status} /> },
                { header: "Pending", cell: (m) => (m.pending_amount_minor > 0 ? formatMoney(m.pending_amount_minor) : "—") },
                {
                  header: "",
                  className: "text-right",
                  cell: (m) =>
                    can("memberships.write") && m.status !== "CANCELLED" ? (
                      <div className="flex justify-end gap-1">
                        <Button size="sm" variant="ghost" onClick={() => setRenewing(m)}>
                          Renew
                        </Button>
                        {m.status !== "EXPIRED" && (
                          <Button size="sm" variant="ghost" onClick={() => cancel(m)}>
                            Cancel
                          </Button>
                        )}
                      </div>
                    ) : null,
                },
              ]}
            />
            <Pagination page={p.page} pageSize={p.page_size} total={p.total} onChange={setPage} />
          </>
        )}
      </QueryState>
      {renewing && <RenewMembershipModal membership={renewing} onClose={() => setRenewing(null)} />}
    </>
  );
}
