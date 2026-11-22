import { useState, type FormEvent } from "react";
import { api, errorMessage } from "../../api/client";
import { useGet, useInvalidate } from "../../api/hooks";
import type { AutomationSettings, MessagingPreferences } from "../../api/types";
import { Button, Card, Checkbox, FormError, Input, PageHeader, QueryState, Textarea } from "../../components/ui";
import { parseDays } from "../../lib/format";

export function AutomationPage() {
  const settings = useGet<AutomationSettings>("/gym/automation-settings");
  const prefs = useGet<MessagingPreferences>("/gym/messaging-preferences");
  return (
    <>
      <PageHeader title="Automation settings" subtitle="Scheduled WhatsApp messages run from n8n. Messages only go to members who opted in." />
      <div className="space-y-6">
        <QueryState query={settings}>{(s) => <SettingsForm initial={s} />}</QueryState>
        <QueryState query={prefs}>{(p) => <TemplatesForm initial={p} />}</QueryState>
      </div>
    </>
  );
}

function SettingsForm({ initial }: { initial: AutomationSettings }) {
  const invalidate = useInvalidate();
  const [s, setS] = useState(initial);
  const [days, setDays] = useState(initial.expiry_days_before.join(", "));
  const [error, setError] = useState<string | null>(null);
  const [saved, setSaved] = useState(false);
  const [busy, setBusy] = useState(false);

  const submit = async (e: FormEvent) => {
    e.preventDefault();
    const parsed = parseDays(days);
    if (!parsed || parsed.length === 0) {
      setError("Reminder days must be comma-separated whole numbers, e.g. 7, 3, 1, 0");
      return;
    }
    setBusy(true);
    setError(null);
    setSaved(false);
    try {
      await api.put("/gym/automation-settings", { ...s, expiry_days_before: parsed });
      await invalidate("/gym/automation-settings");
      setSaved(true);
    } catch (err) {
      setError(errorMessage(err));
    } finally {
      setBusy(false);
    }
  };

  return (
    <Card title="Automations">
      <form onSubmit={submit} className="space-y-4">
        <FormError message={error} />
        {saved && <p className="rounded-md bg-emerald-50 px-3 py-2 text-sm text-emerald-700">Settings saved.</p>}
        <div className="grid gap-4 sm:grid-cols-2">
          <div className="space-y-2">
            <Checkbox label="Membership expiry reminders" checked={s.expiry_enabled} onChange={(e) => setS({ ...s, expiry_enabled: e.target.checked })} />
            {s.expiry_enabled && <Input label="Send reminders (days before expiry)" value={days} onChange={(e) => setDays(e.target.value)} hint="0 means on the expiry day." />}
          </div>
          <div className="space-y-2">
            <Checkbox label="Holiday announcements" checked={s.holiday_enabled} onChange={(e) => setS({ ...s, holiday_enabled: e.target.checked })} />
            <Checkbox label="Birthday wishes" checked={s.birthday_enabled} onChange={(e) => setS({ ...s, birthday_enabled: e.target.checked })} />
            <Checkbox label="Approved promotions" checked={s.campaigns_enabled} onChange={(e) => setS({ ...s, campaigns_enabled: e.target.checked })} />
          </div>
          <div className="space-y-2 sm:col-span-2">
            <Checkbox label="Daily report to the gym" checked={s.daily_report_enabled} onChange={(e) => setS({ ...s, daily_report_enabled: e.target.checked })} />
            {s.daily_report_enabled && (
              <Input
                label="Report phone number"
                value={s.daily_report_phone}
                onChange={(e) => setS({ ...s, daily_report_phone: e.target.value })}
                hint="Leave empty to send to the primary gym administrator's phone."
              />
            )}
          </div>
        </div>
        <Button type="submit" loading={busy}>
          Save automations
        </Button>
      </form>
    </Card>
  );
}

function TemplatesForm({ initial }: { initial: MessagingPreferences }) {
  const invalidate = useInvalidate();
  const [p, setP] = useState(initial);
  const [error, setError] = useState<string | null>(null);
  const [saved, setSaved] = useState(false);
  const [busy, setBusy] = useState(false);

  const submit = async (e: FormEvent) => {
    e.preventDefault();
    setBusy(true);
    setError(null);
    setSaved(false);
    try {
      await api.put("/gym/messaging-preferences", { ...p, daily_message_limit: Number(p.daily_message_limit) });
      await invalidate("/gym/messaging-preferences");
      setSaved(true);
    } catch (err) {
      setError(errorMessage(err));
    } finally {
      setBusy(false);
    }
  };

  return (
    <Card title="Message templates">
      <form onSubmit={submit} className="space-y-4">
        <FormError message={error} />
        {saved && <p className="rounded-md bg-emerald-50 px-3 py-2 text-sm text-emerald-700">Templates saved.</p>}
        <Textarea
          label="Expiry reminder"
          value={p.expiry_template}
          onChange={(e) => setP({ ...p, expiry_template: e.target.value })}
          hint="Placeholders: {{name}}, {{plan}}, {{gym}}, {{date}}, {{days_text}}"
        />
        <Textarea
          label="Holiday announcement"
          value={p.holiday_template}
          onChange={(e) => setP({ ...p, holiday_template: e.target.value })}
          hint="Placeholders: {{name}}, {{gym}}, {{date}}, {{holiday}}, {{description}}"
        />
        <Textarea label="Birthday wish" value={p.birthday_template} onChange={(e) => setP({ ...p, birthday_template: e.target.value })} hint="Placeholders: {{name}}, {{gym}}" />
        <div className="w-56">
          <Input
            label="Daily message limit"
            type="number"
            min={1}
            max={5000}
            value={p.daily_message_limit}
            onChange={(e) => setP({ ...p, daily_message_limit: Number(e.target.value) })}
            hint="Automated sends stop for the day after this many."
          />
        </div>
        <Button type="submit" loading={busy}>
          Save templates
        </Button>
      </form>
    </Card>
  );
}
