import { useState } from "react";
import { useGet } from "../../api/hooks";
import type { MessageLog, Page } from "../../api/types";
import { Badge, PageHeader, Pagination, QueryState, Table } from "../../components/ui";
import { formatDateTime, humanize } from "../../lib/format";

const categories = ["", "EXPIRY_REMINDER", "HOLIDAY", "BIRTHDAY", "CAMPAIGN", "DAILY_REPORT", "TEST"];

export function MessagesPage() {
  const [category, setCategory] = useState("");
  const [page, setPage] = useState(1);
  const query = useGet<Page<MessageLog>>("/gym/messages", { category, page, page_size: 25 });

  return (
    <>
      <PageHeader title="Message history" subtitle="Every WhatsApp message sent or attempted for this gym." />
      <div className="mb-4">
        <select
          value={category}
          onChange={(e) => {
            setCategory(e.target.value);
            setPage(1);
          }}
          className="rounded-md border border-slate-300 px-3 py-2 text-sm"
          aria-label="Category"
        >
          {categories.map((c) => (
            <option key={c} value={c}>
              {c ? humanize(c) : "All categories"}
            </option>
          ))}
        </select>
      </div>
      <QueryState query={query} isEmpty={(p) => p.items.length === 0} emptyMessage="No messages yet.">
        {(p) => (
          <>
            <Table
              rows={p.items}
              rowKey={(m) => m.id}
              columns={[
                { header: "When", cell: (m) => formatDateTime(m.created_at) },
                { header: "Recipient", cell: (m) => `${m.recipient_name || "—"} · ${m.recipient_phone}` },
                { header: "Category", cell: (m) => humanize(m.category) },
                { header: "Status", cell: (m) => <Badge value={m.status} /> },
                { header: "Message", className: "max-w-md whitespace-normal", cell: (m) => <span className="line-clamp-2 text-slate-600" title={m.body}>{m.error ? `${m.body} — ${m.error}` : m.body}</span> },
                { header: "Provider", cell: (m) => m.provider },
              ]}
            />
            <Pagination page={p.page} pageSize={p.page_size} total={p.total} onChange={setPage} />
          </>
        )}
      </QueryState>
    </>
  );
}
