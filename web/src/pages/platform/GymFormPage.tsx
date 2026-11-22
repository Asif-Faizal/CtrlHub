import { useState, type FormEvent } from "react";
import { Link, useNavigate, useParams } from "react-router";
import { api, errorMessage, fieldErrors } from "../../api/client";
import { useGet, useInvalidate } from "../../api/hooks";
import type { OnboardResult, Tenant } from "../../api/types";
import { Button, Card, Checkbox, FormError, Input, PageHeader, QueryState, Select, Textarea } from "../../components/ui";
import { SetupLinkNotice } from "../../components/SetupLinkNotice";
import { openingHoursJSON, openingHoursText } from "../../lib/domain";

export interface GymFields {
  name: string;
  owner_name: string;
  contact_number: string;
  email: string;
  address: string;
  city: string;
  state: string;
  country: string;
  timezone: string;
  currency: string;
  opening_hours_text: string;
  status: "ACTIVE" | "INACTIVE";
  max_users: number;
  whatsapp_enabled: boolean;
}

const emptyGym: GymFields = {
  name: "",
  owner_name: "",
  contact_number: "",
  email: "",
  address: "",
  city: "",
  state: "",
  country: "India",
  timezone: "Asia/Kolkata",
  currency: "INR",
  opening_hours_text: "",
  status: "ACTIVE",
  max_users: 10,
  whatsapp_enabled: true,
};

function fromTenant(t: Tenant): GymFields {
  return {
    name: t.name,
    owner_name: t.owner_name,
    contact_number: t.contact_number,
    email: t.email,
    address: t.address,
    city: t.city,
    state: t.state,
    country: t.country,
    timezone: t.timezone,
    currency: t.currency,
    opening_hours_text: openingHoursText(t.opening_hours),
    status: t.status,
    max_users: t.max_users,
    whatsapp_enabled: t.whatsapp_enabled,
  };
}

function gymPayload(g: GymFields) {
  const { opening_hours_text, ...rest } = g;
  return { ...rest, max_users: Number(rest.max_users), opening_hours: openingHoursJSON(opening_hours_text) };
}

let cachedZones: string[] | null = null;
function timezones(): string[] {
  if (!cachedZones) {
    try {
      cachedZones = Intl.supportedValuesOf("timeZone");
    } catch {
      cachedZones = ["Asia/Kolkata", "UTC"];
    }
  }
  return cachedZones;
}

export function GymFieldset({ value, onChange, errors, withStatus = true }: { value: GymFields; onChange: (v: GymFields) => void; errors: Record<string, string>; withStatus?: boolean }) {
  const set = <K extends keyof GymFields>(k: K, v: GymFields[K]) => onChange({ ...value, [k]: v });
  const err = (k: string) => errors[k] ?? errors[`gym.${k}`];
  return (
    <div className="grid gap-4 sm:grid-cols-2">
      <Input label="Gym name" required value={value.name} onChange={(e) => set("name", e.target.value)} error={err("name")} />
      <Input label="Owner name" required value={value.owner_name} onChange={(e) => set("owner_name", e.target.value)} error={err("owner_name")} />
      <Input label="Contact number" required value={value.contact_number} onChange={(e) => set("contact_number", e.target.value)} error={err("contact_number")} />
      <Input label="Email" type="email" required value={value.email} onChange={(e) => set("email", e.target.value)} error={err("email")} />
      <div className="sm:col-span-2">
        <Input label="Address" value={value.address} onChange={(e) => set("address", e.target.value)} error={err("address")} />
      </div>
      <Input label="City" value={value.city} onChange={(e) => set("city", e.target.value)} />
      <Input label="State" value={value.state} onChange={(e) => set("state", e.target.value)} />
      <Input label="Country" value={value.country} onChange={(e) => set("country", e.target.value)} />
      <div>
        <Input label="Timezone" required list="tz-list" value={value.timezone} onChange={(e) => set("timezone", e.target.value)} error={err("timezone")} />
        <datalist id="tz-list">
          {timezones().map((z) => (
            <option key={z} value={z} />
          ))}
        </datalist>
      </div>
      <div className="sm:col-span-2">
        <Textarea label="Opening hours" placeholder="Mon–Sat 5:00–22:00, Sun 6:00–12:00" value={value.opening_hours_text} onChange={(e) => set("opening_hours_text", e.target.value)} />
      </div>
      {withStatus && (
        <>
          <Input label="Currency" maxLength={3} value={value.currency} onChange={(e) => set("currency", e.target.value.toUpperCase())} error={err("currency")} />
          <Input label="Maximum users" type="number" min={1} max={500} value={value.max_users} onChange={(e) => set("max_users", Number(e.target.value))} error={err("max_users")} />
          <Select
            label="Gym status"
            value={value.status}
            onChange={(e) => set("status", e.target.value as GymFields["status"])}
            options={[
              { value: "ACTIVE", label: "Active" },
              { value: "INACTIVE", label: "Inactive" },
            ]}
          />
          <div className="flex items-end pb-2">
            <Checkbox label="WhatsApp automation enabled" checked={value.whatsapp_enabled} onChange={(e) => set("whatsapp_enabled", e.target.checked)} />
          </div>
        </>
      )}
    </div>
  );
}

export function GymFormPage() {
  const { id } = useParams();
  if (id) return <EditGym id={id} />;
  return <AddGym />;
}

function AddGym() {
  const invalidate = useInvalidate();
  const [gym, setGym] = useState<GymFields>(emptyGym);
  const [admin, setAdmin] = useState({ name: "", email: "", phone: "", password: "" });
  const [error, setError] = useState<string | null>(null);
  const [errors, setErrors] = useState<Record<string, string>>({});
  const [busy, setBusy] = useState(false);
  const [result, setResult] = useState<OnboardResult | null>(null);

  const onSubmit = async (e: FormEvent) => {
    e.preventDefault();
    setBusy(true);
    setError(null);
    setErrors({});
    try {
      const { data } = await api.post<OnboardResult>("/platform/tenants", { gym: gymPayload(gym), admin });
      await invalidate("/platform");
      setResult(data);
    } catch (err) {
      setError(errorMessage(err));
      setErrors(fieldErrors(err));
    } finally {
      setBusy(false);
    }
  };

  if (result) {
    return (
      <>
        <PageHeader title="Gym created" />
        <Card>
          <div className="space-y-4">
            <p className="text-sm text-slate-700">
              <span className="font-semibold">{result.tenant.name}</span> was created with tenant code{" "}
              <span className="font-mono font-semibold">{result.tenant.code}</span>. Its primary administrator is {result.admin.name} ({result.admin.email}).
            </p>
            {result.setup_url ? (
              <SetupLinkNotice url={result.setup_url} />
            ) : (
              <p className="text-sm text-slate-600">The administrator can sign in with the password you set.</p>
            )}
            <Link to={`/platform/gyms/${result.tenant.id}`} className="inline-block text-sm font-medium text-indigo-600">
              Open gym details →
            </Link>
          </div>
        </Card>
      </>
    );
  }

  return (
    <>
      <PageHeader title="Add gym" subtitle="Creates the tenant, its default settings and its primary gym administrator." />
      <form onSubmit={onSubmit} className="space-y-6">
        <FormError message={error} />
        <Card title="Gym details">
          <GymFieldset value={gym} onChange={setGym} errors={errors} />
        </Card>
        <Card title="Primary gym administrator">
          <div className="grid gap-4 sm:grid-cols-2">
            <Input label="Name" required value={admin.name} onChange={(e) => setAdmin({ ...admin, name: e.target.value })} error={errors["admin.name"]} />
            <Input label="Email" type="email" required value={admin.email} onChange={(e) => setAdmin({ ...admin, email: e.target.value })} error={errors["admin.email"]} />
            <Input label="Phone" value={admin.phone} onChange={(e) => setAdmin({ ...admin, phone: e.target.value })} />
            <Input
              label="Initial password (optional)"
              type="password"
              minLength={8}
              value={admin.password}
              onChange={(e) => setAdmin({ ...admin, password: e.target.value })}
              hint="Leave empty to generate a one-time setup link instead."
              error={errors["admin.password"]}
            />
          </div>
        </Card>
        <div className="flex gap-2">
          <Button type="submit" loading={busy}>
            Create gym
          </Button>
          <Link to="/platform/gyms" className="px-3.5 py-2 text-sm text-slate-600">
            Cancel
          </Link>
        </div>
      </form>
    </>
  );
}

function EditGym({ id }: { id: string }) {
  const query = useGet<Tenant>(`/platform/tenants/${id}`);
  return <QueryState query={query}>{(t) => <EditGymForm tenant={t} />}</QueryState>;
}

function EditGymForm({ tenant }: { tenant: Tenant }) {
  const navigate = useNavigate();
  const invalidate = useInvalidate();
  const [gym, setGym] = useState<GymFields>(() => fromTenant(tenant));
  const [error, setError] = useState<string | null>(null);
  const [errors, setErrors] = useState<Record<string, string>>({});
  const [busy, setBusy] = useState(false);

  const onSubmit = async (e: FormEvent) => {
    e.preventDefault();
    setBusy(true);
    setError(null);
    try {
      await api.patch(`/platform/tenants/${tenant.id}`, gymPayload(gym));
      await invalidate("/platform");
      navigate(`/platform/gyms/${tenant.id}`);
    } catch (err) {
      setError(errorMessage(err));
      setErrors(fieldErrors(err));
    } finally {
      setBusy(false);
    }
  };

  return (
    <>
      <PageHeader title={`Edit ${tenant.name}`} subtitle={`Tenant code ${tenant.code}`} />
      <form onSubmit={onSubmit} className="space-y-6">
        <FormError message={error} />
        <Card>
          <GymFieldset value={gym} onChange={setGym} errors={errors} />
        </Card>
        <div className="flex gap-2">
          <Button type="submit" loading={busy}>
            Save changes
          </Button>
          <Link to={`/platform/gyms/${tenant.id}`} className="px-3.5 py-2 text-sm text-slate-600">
            Cancel
          </Link>
        </div>
      </form>
    </>
  );
}
