import { useState, type FormEvent } from "react";
import { api, errorMessage, fieldErrors } from "../../api/client";
import { useGet, useInvalidate } from "../../api/hooks";
import type { DurationType, Plan } from "../../api/types";
import { useAuth } from "../../auth/AuthContext";
import { Can } from "../../auth/guards";
import { Badge, Button, Checkbox, FormError, Input, Modal, PageHeader, QueryState, Select, Table, Textarea } from "../../components/ui";
import { formatMoney, fromMinor, humanize, toMinor } from "../../lib/format";

const durations: DurationType[] = ["MONTHLY", "QUARTERLY", "HALF_YEARLY", "YEARLY", "CUSTOM"];

function durationLabel(p: Plan) {
  return p.duration_type === "CUSTOM" ? `${p.duration_days} days` : humanize(p.duration_type);
}

export function PlansPage() {
  const { can } = useAuth();
  const query = useGet<Plan[]>("/gym/plans");
  const [editing, setEditing] = useState<Plan | "new" | null>(null);

  return (
    <>
      <PageHeader
        title="Membership plans"
        actions={
          <Can perm="plans.write">
            <Button onClick={() => setEditing("new")}>Add plan</Button>
          </Can>
        }
      />
      <QueryState query={query} isEmpty={(l) => (l ?? []).length === 0} emptyMessage="No plans yet. Add your first membership plan.">
        {(list) => (
          <Table
            rows={list}
            rowKey={(p) => p.id}
            onRowClick={can("plans.write") ? (p) => setEditing(p) : undefined}
            columns={[
              { header: "Name", cell: (p) => <span className="font-medium text-slate-900">{p.name}</span> },
              { header: "Duration", cell: durationLabel },
              { header: "Price", cell: (p) => formatMoney(p.price_minor) },
              { header: "Status", cell: (p) => <Badge value={p.is_active ? "ACTIVE" : "INACTIVE"} /> },
              { header: "Description", cell: (p) => <span className="text-slate-500">{p.description || "—"}</span> },
            ]}
          />
        )}
      </QueryState>
      {editing && <PlanModal plan={editing === "new" ? null : editing} onClose={() => setEditing(null)} />}
    </>
  );
}

function PlanModal({ plan, onClose }: { plan: Plan | null; onClose: () => void }) {
  const invalidate = useInvalidate();
  const [name, setName] = useState(plan?.name ?? "");
  const [description, setDescription] = useState(plan?.description ?? "");
  const [durationType, setDurationType] = useState<DurationType>(plan?.duration_type ?? "MONTHLY");
  const [days, setDays] = useState(plan?.duration_days ? String(plan.duration_days) : "");
  const [price, setPrice] = useState(plan ? fromMinor(plan.price_minor) : "");
  const [active, setActive] = useState(plan?.is_active ?? true);
  const [error, setError] = useState<string | null>(null);
  const [errors, setErrors] = useState<Record<string, string>>({});
  const [busy, setBusy] = useState(false);

  const submit = async (e: FormEvent) => {
    e.preventDefault();
    const priceMinor = toMinor(price);
    if (priceMinor === null) {
      setError("Enter a valid price");
      return;
    }
    setBusy(true);
    setError(null);
    setErrors({});
    const body = {
      name,
      description,
      duration_type: durationType,
      duration_days: durationType === "CUSTOM" ? Number(days) : null,
      price_minor: priceMinor,
      is_active: active,
    };
    try {
      if (plan) await api.put(`/gym/plans/${plan.id}`, body);
      else await api.post("/gym/plans", body);
      await invalidate("/gym/plans");
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
      title={plan ? "Edit plan" : "Add plan"}
      onClose={onClose}
      footer={
        <>
          <Button variant="secondary" onClick={onClose}>
            Cancel
          </Button>
          <Button type="submit" form="plan-form" loading={busy}>
            Save
          </Button>
        </>
      }
    >
      <form id="plan-form" onSubmit={submit} className="space-y-4">
        <FormError message={error} />
        <Input label="Name" required value={name} onChange={(e) => setName(e.target.value)} error={errors.name} />
        <div className="grid grid-cols-2 gap-4">
          <Select label="Duration" value={durationType} onChange={(e) => setDurationType(e.target.value as DurationType)} options={durations.map((d) => ({ value: d, label: humanize(d) }))} />
          {durationType === "CUSTOM" ? (
            <Input label="Days" type="number" min={1} required value={days} onChange={(e) => setDays(e.target.value)} error={errors.duration_days} />
          ) : (
            <div />
          )}
        </div>
        <Input label="Price" inputMode="decimal" required value={price} onChange={(e) => setPrice(e.target.value)} error={errors.price_minor} />
        <Textarea label="Description" value={description} onChange={(e) => setDescription(e.target.value)} />
        <Checkbox label="Active (available for new memberships)" checked={active} onChange={(e) => setActive(e.target.checked)} />
        {plan && <p className="text-xs text-slate-500">Changes apply to new memberships only; existing memberships keep their dates and amounts.</p>}
      </form>
    </Modal>
  );
}
