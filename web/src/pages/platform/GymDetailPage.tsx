import { useState } from "react";
import { Link, useParams } from "react-router";
import { api, errorMessage } from "../../api/client";
import { useGet, useInvalidate } from "../../api/hooks";
import type { AuditEntry, Tenant, WhatsAppSession } from "../../api/types";
import { Badge, Button, Card, DetailList, FormError, Modal, PageHeader, QueryState, Table } from "../../components/ui";
import { UserManager } from "../../components/UserManager";
import { formatDateTime, humanize } from "../../lib/format";
import { openingHoursText } from "../../lib/domain";

export function GymDetailPage() {
  const { id = "" } = useParams();
  const query = useGet<Tenant>(`/platform/tenants/${id}`);
  return <QueryState query={query}>{(t) => <GymDetail tenant={t} />}</QueryState>;
}

function GymDetail({ tenant }: { tenant: Tenant }) {
  const invalidate = useInvalidate();
  const [confirm, setConfirm] = useState(false);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const whatsapp = useGet<WhatsAppSession>(`/platform/tenants/${tenant.id}/whatsapp`);
  const audit = useGet<AuditEntry[]>(`/platform/tenants/${tenant.id}/audit`);
  const next = tenant.status === "ACTIVE" ? "INACTIVE" : "ACTIVE";

  const toggleStatus = async () => {
    setBusy(true);
    setError(null);
    try {
      await api.patch(`/platform/tenants/${tenant.id}/status`, { status: next });
      await invalidate("/platform");
      setConfirm(false);
    } catch (err) {
      setError(errorMessage(err));
    } finally {
      setBusy(false);
    }
  };

  return (
    <>
      <PageHeader
        title={tenant.name}
        subtitle={`Tenant code ${tenant.code}`}
        actions={
          <>
            <Link to={`/platform/gyms/${tenant.id}/edit`} className="rounded-md bg-white px-3.5 py-2 text-sm font-medium text-slate-700 ring-1 ring-slate-300 hover:bg-slate-50">
              Edit gym
            </Link>
            <Button variant={next === "INACTIVE" ? "danger" : "primary"} onClick={() => setConfirm(true)}>
              {next === "INACTIVE" ? "Deactivate" : "Activate"}
            </Button>
          </>
        }
      />
      <div className="grid gap-6 lg:grid-cols-3">
        <Card title="Gym details" className="lg:col-span-2">
          <DetailList
            items={[
              ["Status", <Badge key="s" value={tenant.status} />],
              ["Owner", tenant.owner_name],
              ["Contact number", tenant.contact_number],
              ["Email", tenant.email],
              ["Address", [tenant.address, tenant.city, tenant.state, tenant.country].filter(Boolean).join(", ")],
              ["Timezone", tenant.timezone],
              ["Currency", tenant.currency],
              ["Opening hours", openingHoursText(tenant.opening_hours)],
              ["Maximum users", tenant.max_users],
              ["WhatsApp automation", tenant.whatsapp_enabled ? "Enabled" : "Disabled"],
              ["Created", formatDateTime(tenant.created_at)],
            ]}
          />
        </Card>
        <Card title="WhatsApp connection">
          <QueryState query={whatsapp}>
            {(s) => (
              <DetailList
                items={[
                  ["Session", <span key="n" className="font-mono">{s.session_name}</span>],
                  ["Status", <Badge key="st" value={s.status} />],
                  ["Phone", s.phone_number],
                  ["Last checked", formatDateTime(s.last_status_at)],
                ]}
              />
            )}
          </QueryState>
          <p className="mt-4 text-xs text-slate-500">Only the gym's own administrators can connect or disconnect WhatsApp.</p>
        </Card>
      </div>
      <Card title="Gym administrators and staff" className="mt-6">
        <UserManager baseUrl={`/platform/tenants/${tenant.id}/users`} resetUrl={(uid) => `/platform/users/${uid}/reset-password`} />
      </Card>
      <Card title="Audit log" className="mt-6">
        <QueryState query={audit} isEmpty={(l) => (l ?? []).length === 0} emptyMessage="No audit entries yet.">
          {(list) => (
            <Table
              rows={list}
              rowKey={(a) => a.id}
              columns={[
                { header: "When", cell: (a) => formatDateTime(a.created_at) },
                { header: "Action", cell: (a) => humanize(a.action.replace(/\./g, "_")) },
                { header: "Entity", cell: (a) => `${a.entity_type} ${a.entity_id.slice(0, 8)}` },
                { header: "IP", cell: (a) => a.ip || "—" },
              ]}
            />
          )}
        </QueryState>
      </Card>
      <Modal
        open={confirm}
        title={next === "INACTIVE" ? "Deactivate gym?" : "Activate gym?"}
        onClose={() => setConfirm(false)}
        footer={
          <>
            <Button variant="secondary" onClick={() => setConfirm(false)}>
              Cancel
            </Button>
            <Button variant={next === "INACTIVE" ? "danger" : "primary"} loading={busy} onClick={toggleStatus}>
              Confirm
            </Button>
          </>
        }
      >
        <FormError message={error} />
        <p className="text-sm text-slate-600">
          {next === "INACTIVE"
            ? "All users of this gym are signed out immediately and cannot sign in until the gym is reactivated. Automated messages stop."
            : "Users of this gym will be able to sign in again."}
        </p>
      </Modal>
    </>
  );
}
