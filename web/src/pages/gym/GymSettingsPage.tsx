import { useState, type FormEvent } from "react";
import { api, errorMessage, fieldErrors } from "../../api/client";
import { useGet, useInvalidate } from "../../api/hooks";
import type { Tenant } from "../../api/types";
import { useAuth } from "../../auth/AuthContext";
import { Button, Card, DetailList, FormError, PageHeader, QueryState } from "../../components/ui";
import { GymFieldset, type GymFields } from "../platform/GymFormPage";
import { openingHoursJSON, openingHoursText } from "../../lib/domain";

export function GymSettingsPage() {
  const query = useGet<Tenant>("/gym/profile");
  return <QueryState query={query}>{(t) => <Settings tenant={t} />}</QueryState>;
}

function Settings({ tenant }: { tenant: Tenant }) {
  const { can } = useAuth();
  const invalidate = useInvalidate();
  const [form, setForm] = useState<GymFields>({
    name: tenant.name,
    owner_name: tenant.owner_name,
    contact_number: tenant.contact_number,
    email: tenant.email,
    address: tenant.address,
    city: tenant.city,
    state: tenant.state,
    country: tenant.country,
    timezone: tenant.timezone,
    currency: tenant.currency,
    opening_hours_text: openingHoursText(tenant.opening_hours),
    status: tenant.status,
    max_users: tenant.max_users,
    whatsapp_enabled: tenant.whatsapp_enabled,
  });
  const [error, setError] = useState<string | null>(null);
  const [errors, setErrors] = useState<Record<string, string>>({});
  const [saved, setSaved] = useState(false);
  const [busy, setBusy] = useState(false);

  const submit = async (e: FormEvent) => {
    e.preventDefault();
    setBusy(true);
    setError(null);
    setErrors({});
    setSaved(false);
    try {
      await api.put("/gym/profile", {
        name: form.name,
        owner_name: form.owner_name,
        contact_number: form.contact_number,
        email: form.email,
        address: form.address,
        city: form.city,
        state: form.state,
        country: form.country,
        timezone: form.timezone,
        opening_hours: openingHoursJSON(form.opening_hours_text),
      });
      await invalidate("/gym/profile");
      setSaved(true);
    } catch (err) {
      setError(errorMessage(err));
      setErrors(fieldErrors(err));
    } finally {
      setBusy(false);
    }
  };

  return (
    <>
      <PageHeader title="Gym settings" subtitle={`Tenant code ${tenant.code}`} />
      <Card title="Plan limits" className="mb-6">
        <DetailList
          items={[
            ["Maximum users", tenant.max_users],
            ["Currency", tenant.currency],
            ["WhatsApp automation", tenant.whatsapp_enabled ? "Enabled by platform" : "Disabled by platform"],
          ]}
        />
      </Card>
      {can("tenant.update") ? (
        <form onSubmit={submit} className="space-y-4">
          <FormError message={error} />
          {saved && <p className="rounded-md bg-emerald-50 px-3 py-2 text-sm text-emerald-700">Gym profile saved.</p>}
          <Card title="Gym profile">
            <GymFieldset value={form} onChange={setForm} errors={errors} withStatus={false} />
          </Card>
          <Button type="submit" loading={busy}>
            Save changes
          </Button>
        </form>
      ) : (
        <Card title="Gym profile">
          <DetailList
            items={[
              ["Name", tenant.name],
              ["Owner", tenant.owner_name],
              ["Contact number", tenant.contact_number],
              ["Email", tenant.email],
              ["Address", [tenant.address, tenant.city, tenant.state, tenant.country].filter(Boolean).join(", ")],
              ["Timezone", tenant.timezone],
              ["Opening hours", openingHoursText(tenant.opening_hours)],
            ]}
          />
        </Card>
      )}
    </>
  );
}
