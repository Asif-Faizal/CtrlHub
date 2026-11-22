import { useState, type FormEvent } from "react";
import { api, errorMessage, fieldErrors } from "../../api/client";
import { useGet, useInvalidate } from "../../api/hooks";
import type { Holiday } from "../../api/types";
import { useAuth } from "../../auth/AuthContext";
import { Can } from "../../auth/guards";
import { Badge, Button, Checkbox, FormError, Input, Modal, PageHeader, QueryState, Table, Textarea } from "../../components/ui";
import { formatDate, parseDays } from "../../lib/format";

export function HolidaysPage() {
  const { can } = useAuth();
  const invalidate = useInvalidate();
  const [upcoming, setUpcoming] = useState(true);
  const [editing, setEditing] = useState<Holiday | "new" | null>(null);
  const [error, setError] = useState<string | null>(null);
  const query = useGet<Holiday[]>("/gym/holidays", { upcoming });

  const remove = async (h: Holiday) => {
    if (!window.confirm(`Delete holiday "${h.title}"?`)) return;
    setError(null);
    try {
      await api.delete(`/gym/holidays/${h.id}`);
      await invalidate("/gym/holidays");
    } catch (err) {
      setError(errorMessage(err));
    }
  };

  return (
    <>
      <PageHeader
        title="Holidays"
        subtitle="Members who opted in to WhatsApp reminders are notified ahead of each holiday."
        actions={
          <Can perm="holidays.write">
            <Button onClick={() => setEditing("new")}>Add holiday</Button>
          </Can>
        }
      />
      <div className="mb-4">
        <Checkbox label="Upcoming only" checked={upcoming} onChange={(e) => setUpcoming(e.target.checked)} />
      </div>
      <FormError message={error} />
      <QueryState query={query} isEmpty={(l) => (l ?? []).length === 0} emptyMessage="No holidays scheduled.">
        {(list) => (
          <Table
            rows={list}
            rowKey={(h) => h.id}
            columns={[
              { header: "Date", cell: (h) => formatDate(h.holiday_date) },
              { header: "Title", cell: (h) => <span className="font-medium text-slate-900">{h.title}</span> },
              { header: "Notify", cell: (h) => (h.notify_enabled ? <Badge value="ACTIVE" tone="green" /> : <Badge value="OFF" tone="slate" />) },
              { header: "Days before", cell: (h) => (h.notify_enabled ? h.notify_days_before.join(", ") : "—") },
              {
                header: "",
                className: "text-right",
                cell: (h) =>
                  can("holidays.write") ? (
                    <div className="flex justify-end gap-1">
                      <Button size="sm" variant="ghost" onClick={() => setEditing(h)}>
                        Edit
                      </Button>
                      <Button size="sm" variant="ghost" onClick={() => remove(h)}>
                        Delete
                      </Button>
                    </div>
                  ) : null,
              },
            ]}
          />
        )}
      </QueryState>
      {editing && <HolidayModal holiday={editing === "new" ? null : editing} onClose={() => setEditing(null)} />}
    </>
  );
}

function HolidayModal({ holiday, onClose }: { holiday: Holiday | null; onClose: () => void }) {
  const invalidate = useInvalidate();
  const [title, setTitle] = useState(holiday?.title ?? "");
  const [description, setDescription] = useState(holiday?.description ?? "");
  const [date, setDate] = useState(holiday?.holiday_date ?? "");
  const [notify, setNotify] = useState(holiday?.notify_enabled ?? true);
  const [days, setDays] = useState((holiday?.notify_days_before ?? [3, 1]).join(", "));
  const [error, setError] = useState<string | null>(null);
  const [errors, setErrors] = useState<Record<string, string>>({});
  const [busy, setBusy] = useState(false);

  const submit = async (e: FormEvent) => {
    e.preventDefault();
    const parsed = parseDays(days);
    if (parsed === null) {
      setError("Days before must be comma-separated whole numbers, e.g. 3, 1");
      return;
    }
    setBusy(true);
    setError(null);
    setErrors({});
    const body = { title, description, holiday_date: date, notify_enabled: notify, notify_days_before: parsed };
    try {
      if (holiday) await api.put(`/gym/holidays/${holiday.id}`, body);
      else await api.post("/gym/holidays", body);
      await invalidate("/gym/holidays");
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
      title={holiday ? "Edit holiday" : "Add holiday"}
      onClose={onClose}
      footer={
        <>
          <Button variant="secondary" onClick={onClose}>
            Cancel
          </Button>
          <Button type="submit" form="holiday-form" loading={busy}>
            Save
          </Button>
        </>
      }
    >
      <form id="holiday-form" onSubmit={submit} className="space-y-4">
        <FormError message={error} />
        <Input label="Title" required value={title} onChange={(e) => setTitle(e.target.value)} error={errors.title} />
        <Input label="Date" type="date" required value={date} onChange={(e) => setDate(e.target.value)} error={errors.holiday_date} />
        <Textarea label="Message to members (optional)" value={description} onChange={(e) => setDescription(e.target.value)} />
        <Checkbox label="Notify members on WhatsApp" checked={notify} onChange={(e) => setNotify(e.target.checked)} />
        {notify && <Input label="Notify days before" value={days} onChange={(e) => setDays(e.target.value)} hint="Comma-separated, e.g. 3, 1. Use 0 for the same day." />}
      </form>
    </Modal>
  );
}
