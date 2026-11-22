import { useState, type FormEvent } from "react";
import { api, errorMessage } from "../../api/client";
import { useAuth } from "../../auth/AuthContext";
import { Button, Card, DetailList, FormError, Input, PageHeader } from "../../components/ui";
import { humanize } from "../../lib/format";

export function AccountPage() {
  const { user } = useAuth();
  const [current, setCurrent] = useState("");
  const [next, setNext] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [message, setMessage] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);

  const onSubmit = async (e: FormEvent) => {
    e.preventDefault();
    setError(null);
    setMessage(null);
    setBusy(true);
    try {
      await api.post("/auth/change-password", { current_password: current, new_password: next });
      setMessage("Password changed. Other devices have been signed out.");
      setCurrent("");
      setNext("");
    } catch (err) {
      setError(errorMessage(err));
    } finally {
      setBusy(false);
    }
  };

  if (!user) return null;
  return (
    <>
      <PageHeader title="Account" />
      <div className="grid gap-6 lg:grid-cols-2">
        <Card title="Profile">
          <DetailList
            items={[
              ["Name", user.name],
              ["Email", user.email],
              ["Role", humanize(user.role)],
              ["Gym", user.tenant_name ? `${user.tenant_name} (${user.tenant_code})` : "Platform"],
            ]}
          />
        </Card>
        <Card title="Change password">
          <form onSubmit={onSubmit} className="space-y-4">
            <FormError message={error} />
            {message && <p className="rounded-md bg-emerald-50 px-3 py-2 text-sm text-emerald-700">{message}</p>}
            <Input label="Current password" type="password" required value={current} onChange={(e) => setCurrent(e.target.value)} />
            <Input label="New password" type="password" minLength={8} required value={next} onChange={(e) => setNext(e.target.value)} />
            <Button type="submit" loading={busy}>
              Change password
            </Button>
          </form>
        </Card>
      </div>
    </>
  );
}
