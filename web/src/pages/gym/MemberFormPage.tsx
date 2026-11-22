import { useState, type FormEvent } from "react";
import { Link, useNavigate, useParams } from "react-router";
import { api, errorMessage, fieldErrors } from "../../api/client";
import { useGet, useInvalidate } from "../../api/hooks";
import type { Member } from "../../api/types";
import { Button, Card, Checkbox, FormError, Input, PageHeader, QueryState, Select, Textarea } from "../../components/ui";

interface MemberFields {
  full_name: string;
  phone: string;
  email: string;
  gender: string;
  date_of_birth: string;
  address: string;
  emergency_contact: string;
  notes: string;
  joined_on: string;
  status: "ACTIVE" | "INACTIVE";
  whatsapp_opt_in: boolean;
  marketing_opt_in: boolean;
}

const empty: MemberFields = {
  full_name: "",
  phone: "",
  email: "",
  gender: "",
  date_of_birth: "",
  address: "",
  emergency_contact: "",
  notes: "",
  joined_on: "",
  status: "ACTIVE",
  whatsapp_opt_in: false,
  marketing_opt_in: false,
};

function fromMember(m: Member): MemberFields {
  return {
    full_name: m.full_name,
    phone: m.phone,
    email: m.email,
    gender: m.gender,
    date_of_birth: m.date_of_birth ?? "",
    address: m.address,
    emergency_contact: m.emergency_contact,
    notes: m.notes,
    joined_on: m.joined_on,
    status: m.status,
    whatsapp_opt_in: m.whatsapp_opt_in,
    marketing_opt_in: m.marketing_opt_in,
  };
}

export function MemberFormPage() {
  const { id } = useParams();
  if (!id) return <MemberForm initial={empty} />;
  return <EditMember id={id} />;
}

function EditMember({ id }: { id: string }) {
  const query = useGet<Member>(`/gym/members/${id}`);
  return <QueryState query={query}>{(m) => <MemberForm id={id} initial={fromMember(m)} />}</QueryState>;
}

function MemberForm({ id, initial }: { id?: string; initial: MemberFields }) {
  const navigate = useNavigate();
  const invalidate = useInvalidate();
  const [form, setForm] = useState(initial);
  const [error, setError] = useState<string | null>(null);
  const [errors, setErrors] = useState<Record<string, string>>({});
  const [busy, setBusy] = useState(false);
  const set = <K extends keyof MemberFields>(k: K, v: MemberFields[K]) => setForm((f) => ({ ...f, [k]: v }));

  const submit = async (e: FormEvent) => {
    e.preventDefault();
    setBusy(true);
    setError(null);
    setErrors({});
    const body = {
      ...form,
      date_of_birth: form.date_of_birth || null,
      joined_on: form.joined_on || null,
      marketing_opt_in: form.whatsapp_opt_in && form.marketing_opt_in,
    };
    try {
      const { data } = id ? await api.put<Member>(`/gym/members/${id}`, body) : await api.post<Member>("/gym/members", body);
      await invalidate("/gym/members");
      navigate(`/gym/members/${data.id}`);
    } catch (err) {
      setError(errorMessage(err));
      setErrors(fieldErrors(err));
    } finally {
      setBusy(false);
    }
  };

  return (
    <>
      <PageHeader title={id ? "Edit member" : "Add member"} />
      <form onSubmit={submit} className="space-y-6">
        <FormError message={error} />
        <Card>
          <div className="grid gap-4 sm:grid-cols-2">
            <Input label="Full name" required value={form.full_name} onChange={(e) => set("full_name", e.target.value)} error={errors.full_name} />
            <Input label="Phone" required value={form.phone} onChange={(e) => set("phone", e.target.value)} error={errors.phone} hint="10-digit numbers get the default country code." />
            <Input label="Email" type="email" value={form.email} onChange={(e) => set("email", e.target.value)} error={errors.email} />
            <Select
              label="Gender"
              value={form.gender}
              onChange={(e) => set("gender", e.target.value)}
              options={[
                { value: "", label: "Not specified" },
                { value: "MALE", label: "Male" },
                { value: "FEMALE", label: "Female" },
                { value: "OTHER", label: "Other" },
              ]}
            />
            <Input label="Date of birth" type="date" value={form.date_of_birth} onChange={(e) => set("date_of_birth", e.target.value)} error={errors.date_of_birth} />
            <Input label="Joined on" type="date" value={form.joined_on} onChange={(e) => set("joined_on", e.target.value)} hint="Defaults to today." />
            <div className="sm:col-span-2">
              <Input label="Address" value={form.address} onChange={(e) => set("address", e.target.value)} />
            </div>
            <Input label="Emergency contact" value={form.emergency_contact} onChange={(e) => set("emergency_contact", e.target.value)} />
            {id && (
              <Select
                label="Status"
                value={form.status}
                onChange={(e) => set("status", e.target.value as MemberFields["status"])}
                options={[
                  { value: "ACTIVE", label: "Active" },
                  { value: "INACTIVE", label: "Inactive" },
                ]}
              />
            )}
            <div className="sm:col-span-2">
              <Textarea label="Notes" value={form.notes} onChange={(e) => set("notes", e.target.value)} />
            </div>
          </div>
        </Card>
        <Card title="WhatsApp consent">
          <div className="space-y-2">
            <Checkbox label="Member agreed to receive WhatsApp reminders (expiry, holidays, birthdays)" checked={form.whatsapp_opt_in} onChange={(e) => set("whatsapp_opt_in", e.target.checked)} />
            <Checkbox
              label="Member agreed to receive promotional WhatsApp messages"
              checked={form.whatsapp_opt_in && form.marketing_opt_in}
              disabled={!form.whatsapp_opt_in}
              onChange={(e) => set("marketing_opt_in", e.target.checked)}
            />
            <p className="text-xs text-slate-500">Messages are only sent to members who have given consent.</p>
          </div>
        </Card>
        <div className="flex gap-2">
          <Button type="submit" loading={busy}>
            {id ? "Save changes" : "Add member"}
          </Button>
          <Link to={id ? `/gym/members/${id}` : "/gym/members"} className="px-3.5 py-2 text-sm text-slate-600">
            Cancel
          </Link>
        </div>
      </form>
    </>
  );
}
