import { useState } from "react";
import { Link } from "react-router";
import { useGet } from "../../api/hooks";
import type { Member, Page, Payment } from "../../api/types";
import { Can } from "../../auth/guards";
import { Button, Input, Modal, PageHeader, Pagination, QueryState, Table } from "../../components/ui";
import { RecordPaymentModal } from "../../components/MembershipModals";
import { formatDateTime, formatMoney, humanize } from "../../lib/format";

export function PaymentsPage() {
  const [from, setFrom] = useState("");
  const [to, setTo] = useState("");
  const [page, setPage] = useState(1);
  const [picking, setPicking] = useState(false);
  const [memberId, setMemberId] = useState<string | null>(null);
  const query = useGet<Page<Payment>>("/gym/payments", { from: from || undefined, to: to || undefined, page, page_size: 20 });
  const pageTotal = (query.data?.items ?? []).reduce((s, p) => s + p.amount_minor, 0);

  return (
    <>
      <PageHeader
        title="Payments"
        actions={
          <Can perm="payments.write">
            <Button onClick={() => setPicking(true)}>Record payment</Button>
          </Can>
        }
      />
      <div className="mb-4 flex flex-wrap items-end gap-3">
        <div className="w-44">
          <Input label="From" type="date" value={from} onChange={(e) => { setFrom(e.target.value); setPage(1); }} />
        </div>
        <div className="w-44">
          <Input label="To" type="date" value={to} onChange={(e) => { setTo(e.target.value); setPage(1); }} />
        </div>
        {query.data && query.data.items.length > 0 && <p className="pb-2 text-sm text-slate-600">This page: {formatMoney(pageTotal)}</p>}
      </div>
      <QueryState query={query} isEmpty={(p) => p.items.length === 0} emptyMessage="No payments in this period.">
        {(p) => (
          <>
            <Table
              rows={p.items}
              rowKey={(x) => x.id}
              columns={[
                { header: "Date", cell: (x) => formatDateTime(x.paid_at) },
                { header: "Member", cell: (x) => <Link className="text-indigo-600" to={`/gym/members/${x.member_id}`}>{x.member_name}</Link> },
                { header: "Amount", cell: (x) => <span className="font-medium">{formatMoney(x.amount_minor)}</span> },
                { header: "Method", cell: (x) => humanize(x.method) },
                { header: "Reference", cell: (x) => x.reference || "—" },
              ]}
            />
            <Pagination page={p.page} pageSize={p.page_size} total={p.total} onChange={setPage} />
          </>
        )}
      </QueryState>
      {picking && (
        <MemberPicker
          title="Record payment for…"
          onClose={() => setPicking(false)}
          onPick={(m) => {
            setPicking(false);
            setMemberId(m.id);
          }}
        />
      )}
      {memberId && <RecordPaymentModal memberId={memberId} onClose={() => setMemberId(null)} />}
    </>
  );
}

export function MemberPicker({ title, onPick, onClose }: { title: string; onPick: (m: Member) => void; onClose: () => void }) {
  const [search, setSearch] = useState("");
  const query = useGet<Page<Member>>("/gym/members", { search, page_size: 8 }, { enabled: search.trim().length >= 2 });
  return (
    <Modal open title={title} onClose={onClose}>
      <Input label="Search member" autoFocus placeholder="Name or phone (at least 2 characters)" value={search} onChange={(e) => setSearch(e.target.value)} />
      {search.trim().length >= 2 && (
        <QueryState query={query} isEmpty={(p) => p.items.length === 0} emptyMessage="No matching members.">
          {(p) => (
            <ul className="divide-y divide-slate-100 rounded-md ring-1 ring-slate-200">
              {p.items.map((m) => (
                <li key={m.id}>
                  <button className="flex w-full justify-between px-3 py-2 text-left text-sm hover:bg-slate-50" onClick={() => onPick(m)}>
                    <span className="font-medium">{m.full_name}</span>
                    <span className="text-slate-500">{m.phone}</span>
                  </button>
                </li>
              ))}
            </ul>
          )}
        </QueryState>
      )}
    </Modal>
  );
}
