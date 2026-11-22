import { useState, type FormEvent } from "react";
import { useNavigate } from "react-router";
import { api, errorMessage, fieldErrors } from "../../api/client";
import { useGet, useInvalidate } from "../../api/hooks";
import type { Campaign, CampaignAudience, Member, Page } from "../../api/types";
import { Can } from "../../auth/guards";
import { Badge, Button, FormError, Input, Modal, PageHeader, QueryState, Select, Table, Textarea } from "../../components/ui";
import { formatDateTime } from "../../lib/format";
import { audienceLabel, audiences } from "../../lib/domain";

export function PromotionsPage() {
  const navigate = useNavigate();
  const [creating, setCreating] = useState(false);
  const query = useGet<Campaign[]>("/gym/campaigns");

  return (
    <>
      <PageHeader
        title="Promotions"
        subtitle="Promotional WhatsApp campaigns need approval and are sent only to people who opted in to promotions."
        actions={
          <Can perm="campaigns.write">
            <Button onClick={() => setCreating(true)}>New promotion</Button>
          </Can>
        }
      />
      <QueryState query={query} isEmpty={(l) => (l ?? []).length === 0} emptyMessage="No promotions yet.">
        {(list) => (
          <Table
            rows={list}
            rowKey={(c) => c.id}
            onRowClick={(c) => navigate(`/gym/promotions/${c.id}`)}
            columns={[
              { header: "Name", cell: (c) => <span className="font-medium text-slate-900">{c.name}</span> },
              { header: "Audience", cell: audienceLabel },
              { header: "Status", cell: (c) => <Badge value={c.status} /> },
              { header: "Recipients", cell: (c) => (c.recipients_total ? `${c.sent_count}/${c.recipients_total} sent` : "—") },
              { header: "Created", cell: (c) => formatDateTime(c.created_at) },
            ]}
          />
        )}
      </QueryState>
      {creating && <CampaignModal onClose={() => setCreating(false)} onSaved={(c) => navigate(`/gym/promotions/${c.id}`)} />}
    </>
  );
}

export function CampaignModal({ campaign, onClose, onSaved }: { campaign?: Campaign; onClose: () => void; onSaved: (c: Campaign) => void }) {
  const invalidate = useInvalidate();
  const [name, setName] = useState(campaign?.name ?? "");
  const [message, setMessage] = useState(campaign?.message ?? "");
  const [audience, setAudience] = useState<CampaignAudience>(campaign?.audience ?? "ACTIVE_MEMBERS");
  const [expiringDays, setExpiringDays] = useState(String(campaign?.audience_params.expiring_in_days ?? 7));
  const [leadDays, setLeadDays] = useState(String(campaign?.audience_params.leads_created_days ?? 30));
  const [selected, setSelected] = useState<{ id: string; name: string }[]>(
    (campaign?.audience_params.member_ids ?? []).map((id) => ({ id, name: id.slice(0, 8) })),
  );
  const [error, setError] = useState<string | null>(null);
  const [errors, setErrors] = useState<Record<string, string>>({});
  const [busy, setBusy] = useState(false);

  const submit = async (e: FormEvent) => {
    e.preventDefault();
    setBusy(true);
    setError(null);
    setErrors({});
    const audience_params =
      audience === "EXPIRING_SOON"
        ? { expiring_in_days: Number(expiringDays) }
        : audience === "NEW_LEADS"
          ? { leads_created_days: Number(leadDays) }
          : audience === "SELECTED_MEMBERS"
            ? { member_ids: selected.map((s) => s.id) }
            : {};
    try {
      const body = { name, message, audience, audience_params };
      const { data } = campaign ? await api.put<Campaign>(`/gym/campaigns/${campaign.id}`, body) : await api.post<Campaign>("/gym/campaigns", body);
      await invalidate("/gym/campaigns");
      onSaved(data);
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
      title={campaign ? "Edit promotion" : "New promotion"}
      onClose={onClose}
      footer={
        <>
          <Button variant="secondary" onClick={onClose}>
            Cancel
          </Button>
          <Button type="submit" form="campaign-form" loading={busy}>
            Save draft
          </Button>
        </>
      }
    >
      <form id="campaign-form" onSubmit={submit} className="space-y-4">
        <FormError message={error} />
        <Input label="Name" required value={name} onChange={(e) => setName(e.target.value)} error={errors.name} />
        <Textarea label="Message" required rows={5} maxLength={1500} value={message} onChange={(e) => setMessage(e.target.value)} error={errors.message} hint="Use {{name}} for the recipient's name and {{gym}} for the gym name." />
        <Select label="Audience" value={audience} onChange={(e) => setAudience(e.target.value as CampaignAudience)} options={audiences} error={errors.audience} />
        {audience === "EXPIRING_SOON" && <Input label="Expiring within (days)" type="number" min={1} max={90} value={expiringDays} onChange={(e) => setExpiringDays(e.target.value)} />}
        {audience === "NEW_LEADS" && <Input label="Leads added in the last (days)" type="number" min={1} max={365} value={leadDays} onChange={(e) => setLeadDays(e.target.value)} />}
        {audience === "SELECTED_MEMBERS" && <SelectMembers selected={selected} onChange={setSelected} />}
      </form>
    </Modal>
  );
}

function SelectMembers({ selected, onChange }: { selected: { id: string; name: string }[]; onChange: (v: { id: string; name: string }[]) => void }) {
  const [search, setSearch] = useState("");
  const query = useGet<Page<Member>>("/gym/members", { search, page_size: 6 }, { enabled: search.trim().length >= 2 });
  const add = (m: Member) => {
    if (!selected.some((s) => s.id === m.id)) onChange([...selected, { id: m.id, name: m.full_name }]);
    setSearch("");
  };
  return (
    <div className="space-y-2">
      <Input label="Add members" placeholder="Search by name or phone" value={search} onChange={(e) => setSearch(e.target.value)} />
      {search.trim().length >= 2 && query.data && (
        <ul className="divide-y divide-slate-100 rounded-md ring-1 ring-slate-200">
          {query.data.items.map((m) => (
            <li key={m.id}>
              <button type="button" className="w-full px-3 py-1.5 text-left text-sm hover:bg-slate-50" onClick={() => add(m)}>
                {m.full_name} <span className="text-slate-400">{m.phone}</span>
                {!m.marketing_opt_in && <span className="ml-2 text-xs text-amber-600">not opted in</span>}
              </button>
            </li>
          ))}
        </ul>
      )}
      <div className="flex flex-wrap gap-1.5">
        {selected.map((s) => (
          <span key={s.id} className="inline-flex items-center gap-1 rounded-full bg-indigo-50 px-2 py-0.5 text-xs text-indigo-700">
            {s.name}
            <button type="button" aria-label={`Remove ${s.name}`} onClick={() => onChange(selected.filter((x) => x.id !== s.id))}>
              ×
            </button>
          </span>
        ))}
      </div>
    </div>
  );
}
