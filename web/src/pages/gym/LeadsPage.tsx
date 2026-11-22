import { useState, type FormEvent } from "react";
import { api, errorMessage, fieldErrors } from "../../api/client";
import { useGet, useInvalidate } from "../../api/hooks";
import type { Lead, LeadStatus } from "../../api/types";
import { useAuth } from "../../auth/AuthContext";
import { Can } from "../../auth/guards";
import { Badge, Button, Checkbox, FormError, Input, Modal, PageHeader, QueryState, Select, Table, Textarea } from "../../components/ui";
import { formatDate, humanize } from "../../lib/format";

const statuses: LeadStatus[] = ["NEW", "CONTACTED", "CONVERTED", "LOST"];

export function LeadsPage() {
  const { can } = useAuth();
  const [status, setStatus] = useState("");
  const [editing, setEditing] = useState<Lead | "new" | null>(null);
  const query = useGet<Lead[]>("/gym/leads", { status });

  return (
    <>
      <PageHeader
        title="Leads"
        subtitle="Prospective members. Leads who opted in can receive promotions."
        actions={
          <Can perm="leads.write">
            <Button onClick={() => setEditing("new")}>Add lead</Button>
          </Can>
        }
      />
      <div className="mb-4">
        <select value={status} onChange={(e) => setStatus(e.target.value)} className="rounded-md border border-slate-300 px-3 py-2 text-sm" aria-label="Lead status">
          <option value="">All statuses</option>
          {statuses.map((s) => (
            <option key={s} value={s}>
              {humanize(s)}
            </option>
          ))}
        </select>
      </div>
      <QueryState query={query} isEmpty={(l) => (l ?? []).length === 0} emptyMessage="No leads yet.">
        {(list) => (
          <Table
            rows={list}
            rowKey={(l) => l.id}
            onRowClick={can("leads.write") ? (l) => setEditing(l) : undefined}
            columns={[
              { header: "Name", cell: (l) => <span className="font-medium text-slate-900">{l.full_name}</span> },
              { header: "Phone", cell: (l) => l.phone },
              { header: "Source", cell: (l) => l.source || "—" },
              { header: "Status", cell: (l) => <Badge value={l.status} /> },
              { header: "Promotions", cell: (l) => (l.marketing_opt_in ? "Opted in" : "—") },
              { header: "Added", cell: (l) => formatDate(l.created_at) },
            ]}
          />
        )}
      </QueryState>
      {editing && <LeadModal lead={editing === "new" ? null : editing} onClose={() => setEditing(null)} />}
    </>
  );
}

function LeadModal({ lead, onClose }: { lead: Lead | null; onClose: () => void }) {
  const invalidate = useInvalidate();
  const [form, setForm] = useState({
    full_name: lead?.full_name ?? "",
    phone: lead?.phone ?? "",
    email: lead?.email ?? "",
    source: lead?.source ?? "",
    status: lead?.status ?? "NEW",
    whatsapp_opt_in: lead?.whatsapp_opt_in ?? false,
    marketing_opt_in: lead?.marketing_opt_in ?? false,
    notes: lead?.notes ?? "",
  });
  const [error, setError] = useState<string | null>(null);
  const [errors, setErrors] = useState<Record<string, string>>({});
  const [busy, setBusy] = useState(false);

  const submit = async (e: FormEvent) => {
    e.preventDefault();
    setBusy(true);
    setError(null);
    setErrors({});
    const body = { ...form, marketing_opt_in: form.whatsapp_opt_in && form.marketing_opt_in };
    try {
      if (lead) await api.put(`/gym/leads/${lead.id}`, body);
      else await api.post("/gym/leads", body);
      await invalidate("/gym/leads");
      onClose();
    } catch (err) {
      setError(errorMessage(err));
      setErrors(fieldErrors(err));
    } finally {
      setBusy(false);
    }
  };

  return (
    <Modal
      open
      title={lead ? "Edit lead" : "Add lead"}
      onClose={onClose}
      footer={
        <>
          <Button variant="secondary" onClick={onClose}>
            Cancel
          </Button>
          <Button type="submit" form="lead-form" loading={busy}>
            Save
          </Button>
        </>
      }
    >
      <form id="lead-form" onSubmit={submit} className="space-y-4">
        <FormError message={error} />
        <Input label="Full name" required value={form.full_name} onChange={(e) => setForm({ ...form, full_name: e.target.value })} error={errors.full_name} />
        <div className="grid grid-cols-2 gap-4">
          <Input label="Phone" required value={form.phone} onChange={(e) => setForm({ ...form, phone: e.target.value })} error={errors.phone} />
          <Input label="Email" type="email" value={form.email} onChange={(e) => setForm({ ...form, email: e.target.value })} error={errors.email} />
          <Input label="Source" placeholder="Walk-in, Instagram…" value={form.source} onChange={(e) => setForm({ ...form, source: e.target.value })} />
          <Select label="Status" value={form.status} onChange={(e) => setForm({ ...form, status: e.target.value as LeadStatus })} options={statuses.map((s) => ({ value: s, label: humanize(s) }))} />
        </div>
        <Textarea label="Notes" value={form.notes} onChange={(e) => setForm({ ...form, notes: e.target.value })} />
        <Checkbox label="Agreed to receive WhatsApp messages" checked={form.whatsapp_opt_in} onChange={(e) => setForm({ ...form, whatsapp_opt_in: e.target.checked })} />
        <Checkbox
          label="Agreed to receive promotions"
          disabled={!form.whatsapp_opt_in}
          checked={form.whatsapp_opt_in && form.marketing_opt_in}
          onChange={(e) => setForm({ ...form, marketing_opt_in: e.target.checked })}
        />
      </form>
    </Modal>
  );
}
