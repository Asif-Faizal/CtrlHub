import { useState, type FormEvent } from "react";
import { api, errorMessage, fieldErrors } from "../api/client";
import { useGet, useInvalidate } from "../api/hooks";
import { GYM_ROLES, type CreatedUser, type Role, type TenantUser } from "../api/types";
import { useAuth } from "../auth/AuthContext";
import { formatDateTime, humanize } from "../lib/format";
import { Badge, Button, FormError, Input, Modal, QueryState, Select, Table } from "./ui";
import { SetupLinkNotice } from "./SetupLinkNotice";

interface UserManagerProps {
  // Base collection URL, e.g. /gym/users or /platform/tenants/{id}/users.
  baseUrl: string;
  resetUrl: (userId: string) => string;
}

const roleOptions = GYM_ROLES.map((r) => ({ value: r, label: humanize(r) }));

export function UserManager({ baseUrl, resetUrl }: UserManagerProps) {
  const { user: me } = useAuth();
  const query = useGet<TenantUser[]>(baseUrl);
  const invalidate = useInvalidate();
  const [creating, setCreating] = useState(false);
  const [editing, setEditing] = useState<TenantUser | null>(null);
  const [setupUrl, setSetupUrl] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  const reset = async (u: TenantUser) => {
    setError(null);
    try {
      const { data } = await api.post<{ setup_url: string }>(resetUrl(u.id));
      setSetupUrl(data.setup_url);
      await invalidate(baseUrl);
    } catch (err) {
      setError(errorMessage(err));
    }
  };

  return (
    <div className="space-y-4">
      <div className="flex justify-end">
        <Button onClick={() => setCreating(true)}>Add user</Button>
      </div>
      <FormError message={error} />
      {setupUrl && <SetupLinkNotice url={setupUrl} onDismiss={() => setSetupUrl(null)} />}
      <QueryState query={query} isEmpty={(l) => (l ?? []).length === 0} emptyMessage="No users yet.">
        {(list) => (
          <Table
            rows={list}
            rowKey={(u) => u.id}
            columns={[
              {
                header: "Name",
                cell: (u) => (
                  <span className="font-medium text-slate-900">
                    {u.name} {u.is_primary && <span className="ml-1 text-xs text-indigo-600">(primary)</span>}
                  </span>
                ),
              },
              { header: "Email", cell: (u) => u.email },
              { header: "Role", cell: (u) => humanize(u.role) },
              { header: "Status", cell: (u) => <Badge value={u.status} /> },
              { header: "Last login", cell: (u) => formatDateTime(u.last_login_at) },
              {
                header: "",
                className: "text-right",
                cell: (u) => (
                  <div className="flex justify-end gap-1">
                    <Button size="sm" variant="ghost" onClick={() => setEditing(u)}>
                      Edit
                    </Button>
                    {u.id !== me?.id && (
                      <Button size="sm" variant="ghost" onClick={() => reset(u)}>
                        Reset password
                      </Button>
                    )}
                  </div>
                ),
              },
            ]}
          />
        )}
      </QueryState>
      <CreateUserModal
        open={creating}
        baseUrl={baseUrl}
        onClose={() => setCreating(false)}
        onCreated={async (res) => {
          setCreating(false);
          if (res.setup_url) setSetupUrl(res.setup_url);
          await invalidate(baseUrl);
        }}
      />
      {editing && (
        <EditUserModal
          user={editing}
          baseUrl={baseUrl}
          onClose={() => setEditing(null)}
          onSaved={async () => {
            setEditing(null);
            await invalidate(baseUrl);
          }}
        />
      )}
    </div>
  );
}

function CreateUserModal({ open, baseUrl, onClose, onCreated }: { open: boolean; baseUrl: string; onClose: () => void; onCreated: (r: CreatedUser) => void }) {
  const [form, setForm] = useState({ name: "", email: "", phone: "", role: "RECEPTIONIST" as Role, password: "" });
  const [error, setError] = useState<string | null>(null);
  const [errors, setErrors] = useState<Record<string, string>>({});
  const [busy, setBusy] = useState(false);

  const submit = async (e: FormEvent) => {
    e.preventDefault();
    setBusy(true);
    setError(null);
    setErrors({});
    try {
      const { data } = await api.post<CreatedUser>(baseUrl, form);
      setForm({ name: "", email: "", phone: "", role: "RECEPTIONIST", password: "" });
      onCreated(data);
    } catch (err) {
      setError(errorMessage(err));
      setErrors(fieldErrors(err));
    } finally {
      setBusy(false);
    }
  };

  return (
    <Modal
      open={open}
      title="Add user"
      onClose={onClose}
      footer={
        <>
          <Button variant="secondary" onClick={onClose}>
            Cancel
          </Button>
          <Button type="submit" form="create-user" loading={busy}>
            Create user
          </Button>
        </>
      }
    >
      <form id="create-user" onSubmit={submit} className="space-y-4">
        <FormError message={error} />
        <Input label="Name" required value={form.name} onChange={(e) => setForm({ ...form, name: e.target.value })} error={errors.name} />
        <Input label="Email" type="email" required value={form.email} onChange={(e) => setForm({ ...form, email: e.target.value })} error={errors.email} />
        <Input label="Phone" value={form.phone} onChange={(e) => setForm({ ...form, phone: e.target.value })} />
        <Select label="Role" value={form.role} onChange={(e) => setForm({ ...form, role: e.target.value as Role })} options={roleOptions} error={errors.role} />
        <Input
          label="Initial password (optional)"
          type="password"
          minLength={8}
          value={form.password}
          onChange={(e) => setForm({ ...form, password: e.target.value })}
          hint="Leave empty to generate a one-time setup link."
          error={errors.password}
        />
      </form>
    </Modal>
  );
}

function EditUserModal({ user, baseUrl, onClose, onSaved }: { user: TenantUser; baseUrl: string; onClose: () => void; onSaved: () => void }) {
  const [form, setForm] = useState({
    name: user.name,
    phone: user.phone,
    role: user.role,
    status: user.status === "INACTIVE" ? "INACTIVE" : "ACTIVE",
  });
  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);

  const submit = async (e: FormEvent) => {
    e.preventDefault();
    setBusy(true);
    setError(null);
    try {
      await api.patch(`${baseUrl}/${user.id}`, form);
      onSaved();
    } catch (err) {
      setError(errorMessage(err));
    } finally {
      setBusy(false);
    }
  };

  return (
    <Modal
      open
      title={`Edit ${user.name}`}
      onClose={onClose}
      footer={
        <>
          <Button variant="secondary" onClick={onClose}>
            Cancel
          </Button>
          <Button type="submit" form="edit-user" loading={busy}>
            Save
          </Button>
        </>
      }
    >
      <form id="edit-user" onSubmit={submit} className="space-y-4">
        <FormError message={error} />
        <Input label="Name" required value={form.name} onChange={(e) => setForm({ ...form, name: e.target.value })} />
        <Input label="Phone" value={form.phone} onChange={(e) => setForm({ ...form, phone: e.target.value })} />
        <Select label="Role" value={form.role} onChange={(e) => setForm({ ...form, role: e.target.value as Role })} options={roleOptions} />
        <Select
          label="Status"
          value={form.status}
          onChange={(e) => setForm({ ...form, status: e.target.value })}
          options={[
            { value: "ACTIVE", label: "Active" },
            { value: "INACTIVE", label: "Inactive (signs the user out everywhere)" },
          ]}
        />
      </form>
    </Modal>
  );
}
