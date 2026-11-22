import { useState, type FormEvent } from "react";
import { api, errorMessage } from "../api/client";
import { useGet, useInvalidate } from "../api/hooks";
import { PAYMENT_METHODS, type Membership, type Page, type Plan } from "../api/types";
import { formatDate, formatMoney, fromMinor, humanize, toMinor } from "../lib/format";
import { Button, FormError, Input, Modal, Select } from "./ui";

const methodOptions = PAYMENT_METHODS.map((m) => ({ value: m, label: humanize(m) }));

// Refresh everything that shows membership or payment state.
const AFFECTED = ["/gym/members", "/gym/memberships", "/gym/payments", "/gym/reports"];

function usePlans() {
  return useGet<Plan[]>("/gym/plans", { active: true });
}

function amountError(raw: string, required: boolean): string | null {
  if (!raw.trim()) return required ? "Enter an amount" : null;
  return toMinor(raw) === null ? "Enter a valid amount, e.g. 1499 or 1499.50" : null;
}

interface MembershipFormProps {
  title: string;
  submitLabel: string;
  defaultPlanId?: string;
  showStartDate?: boolean;
  note?: string;
  onSubmit: (body: Record<string, unknown>) => Promise<void>;
  onClose: () => void;
}

function MembershipForm({ title, submitLabel, defaultPlanId, showStartDate, note, onSubmit, onClose }: MembershipFormProps) {
  const plans = usePlans();
  const planList = plans.data ?? [];
  const [planId, setPlanId] = useState(defaultPlanId ?? "");
  const effectivePlanId = planId || planList[0]?.id || "";
  const plan = planList.find((p) => p.id === effectivePlanId);
  const [startDate, setStartDate] = useState("");
  const [total, setTotal] = useState<string | null>(null);
  const [initial, setInitial] = useState("");
  const [method, setMethod] = useState<string>("CASH");
  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);
  const totalText = total ?? (plan ? fromMinor(plan.price_minor) : "");

  const submit = async (e: FormEvent) => {
    e.preventDefault();
    const bad = amountError(totalText, true) ?? amountError(initial, false);
    if (bad) {
      setError(bad);
      return;
    }
    if (!effectivePlanId) {
      setError("Create an active membership plan first");
      return;
    }
    setBusy(true);
    setError(null);
    try {
      await onSubmit({
        plan_id: effectivePlanId,
        ...(showStartDate && startDate ? { start_date: startDate } : {}),
        total_amount_minor: toMinor(totalText),
        initial_payment_minor: initial.trim() ? toMinor(initial) : 0,
        payment_method: method,
      });
    } catch (err) {
      setError(errorMessage(err));
    } finally {
      setBusy(false);
    }
  };

  return (
    <Modal
      open
      title={title}
      onClose={onClose}
      footer={
        <>
          <Button variant="secondary" onClick={onClose}>
            Cancel
          </Button>
          <Button type="submit" form="membership-form" loading={busy} disabled={plans.isPending}>
            {submitLabel}
          </Button>
        </>
      }
    >
      <form id="membership-form" onSubmit={submit} className="space-y-4">
        <FormError message={error} />
        {note && <p className="text-sm text-slate-600">{note}</p>}
        <Select
          label="Plan"
          value={effectivePlanId}
          onChange={(e) => {
            setPlanId(e.target.value);
            setTotal(null);
          }}
          options={planList.map((p) => ({ value: p.id, label: `${p.name} · ${humanize(p.duration_type)} · ${formatMoney(p.price_minor)}` }))}
        />
        {showStartDate && <Input label="Start date" type="date" value={startDate} onChange={(e) => setStartDate(e.target.value)} hint="Defaults to today." />}
        <Input label="Total amount" inputMode="decimal" value={totalText} onChange={(e) => setTotal(e.target.value)} hint="Defaults to the plan price; adjust for discounts." />
        <div className="grid grid-cols-2 gap-4">
          <Input label="Paid now (optional)" inputMode="decimal" value={initial} onChange={(e) => setInitial(e.target.value)} />
          <Select label="Payment method" value={method} onChange={(e) => setMethod(e.target.value)} options={methodOptions} />
        </div>
      </form>
    </Modal>
  );
}

export function AssignMembershipModal({ memberId, onClose }: { memberId: string; onClose: () => void }) {
  const invalidate = useInvalidate();
  return (
    <MembershipForm
      title="Assign membership"
      submitLabel="Assign"
      showStartDate
      onClose={onClose}
      onSubmit={async (body) => {
        await api.post("/gym/memberships", { ...body, member_id: memberId });
        await invalidate(...AFFECTED);
        onClose();
      }}
    />
  );
}

export function RenewMembershipModal({ membership, onClose }: { membership: Membership; onClose: () => void }) {
  const invalidate = useInvalidate();
  return (
    <MembershipForm
      title={`Renew ${membership.member_name ?? "membership"}`}
      submitLabel="Renew"
      defaultPlanId={membership.plan_id}
      note={`The current membership (ending ${formatDate(membership.end_date)}) is kept in history. The renewal starts the day after it ends, or today if it has already expired.`}
      onClose={onClose}
      onSubmit={async (body) => {
        await api.post(`/gym/memberships/${membership.id}/renew`, body);
        await invalidate(...AFFECTED);
        onClose();
      }}
    />
  );
}

export function RecordPaymentModal({ memberId, membershipId, onClose }: { memberId: string; membershipId?: string; onClose: () => void }) {
  const invalidate = useInvalidate();
  const memberships = useGet<Page<Membership>>(`/gym/members/${memberId}/memberships`);
  const withDue = (memberships.data?.items ?? []).filter((m) => m.pending_amount_minor > 0 && m.status !== "CANCELLED");
  const [selected, setSelected] = useState(membershipId ?? "");
  const effective = selected || withDue[0]?.id || "";
  const target = withDue.find((m) => m.id === effective);
  const [amount, setAmount] = useState("");
  const [method, setMethod] = useState("CASH");
  const [reference, setReference] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);

  const submit = async (e: FormEvent) => {
    e.preventDefault();
    const minor = toMinor(amount);
    if (!minor) {
      setError("Enter a valid amount greater than zero");
      return;
    }
    setBusy(true);
    setError(null);
    try {
      await api.post("/gym/payments", {
        member_id: memberId,
        ...(effective ? { membership_id: effective } : {}),
        amount_minor: minor,
        method,
        reference,
      });
      await invalidate(...AFFECTED);
      onClose();
    } catch (err) {
      setError(errorMessage(err));
    } finally {
      setBusy(false);
    }
  };

  return (
    <Modal
      open
      title="Record payment"
      onClose={onClose}
      footer={
        <>
          <Button variant="secondary" onClick={onClose}>
            Cancel
          </Button>
          <Button type="submit" form="payment-form" loading={busy}>
            Record payment
          </Button>
        </>
      }
    >
      <form id="payment-form" onSubmit={submit} className="space-y-4">
        <FormError message={error} />
        <Select
          label="Apply to membership"
          value={effective}
          onChange={(e) => setSelected(e.target.value)}
          options={[
            ...withDue.map((m) => ({ value: m.id, label: `${m.plan_name} (${formatDate(m.start_date)} – ${formatDate(m.end_date)}) · due ${formatMoney(m.pending_amount_minor)}` })),
            { value: "", label: "Not linked to a membership" },
          ]}
        />
        {target && <p className="text-xs text-slate-500">Outstanding: {formatMoney(target.pending_amount_minor)}. Payments cannot exceed the outstanding amount.</p>}
        <div className="grid grid-cols-2 gap-4">
          <Input label="Amount" inputMode="decimal" required value={amount} onChange={(e) => setAmount(e.target.value)} />
          <Select label="Method" value={method} onChange={(e) => setMethod(e.target.value)} options={methodOptions} />
        </div>
        <Input label="Reference (optional)" value={reference} onChange={(e) => setReference(e.target.value)} hint="UPI transaction ID, receipt number…" />
      </form>
    </Modal>
  );
}
