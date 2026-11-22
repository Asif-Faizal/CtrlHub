import { useState, type FormEvent } from "react";
import { api, errorMessage } from "../../api/client";
import { useGet, useInvalidate } from "../../api/hooks";
import type { MessageLog, QRCode, WhatsAppSession, WhatsAppStatusResponse } from "../../api/types";
import { useAuth } from "../../auth/AuthContext";
import { Badge, Button, Card, DetailList, FormError, Input, PageHeader, QueryState, Textarea } from "../../components/ui";
import { formatDateTime } from "../../lib/format";

const RISK =
  "WhatsApp connectivity uses WAHA, an unofficial WhatsApp Web integration. WhatsApp may restrict or ban numbers used this way, especially for bulk or unsolicited messages. Use a dedicated number and only message members who opted in.";

export function WhatsAppPage() {
  const { can } = useAuth();
  const invalidate = useInvalidate();
  const status = useGet<WhatsAppStatusResponse>("/gym/whatsapp", undefined, {
    refetchInterval: (q) => {
      const s = q.state.data?.session.status;
      return s === "STARTING" || s === "SCAN_QR_CODE" ? 3_000 : 30_000;
    },
  });
  const [busy, setBusy] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  const act = async (action: "connect" | "disconnect") => {
    if (action === "disconnect" && !window.confirm("Disconnect WhatsApp? Automated messages stop until you reconnect.")) return;
    setBusy(action);
    setError(null);
    try {
      await api.post<WhatsAppSession>(`/gym/whatsapp/${action}`);
      await invalidate("/gym/whatsapp");
    } catch (err) {
      setError(errorMessage(err));
    } finally {
      setBusy(null);
    }
  };

  return (
    <>
      <PageHeader title="WhatsApp connection" subtitle="Each gym connects its own WhatsApp number." />
      <div className="mb-6 rounded-md bg-amber-50 p-4 text-sm text-amber-800 ring-1 ring-amber-200">{RISK}</div>
      <FormError message={error} />
      <QueryState query={status}>
        {({ session, provider }) => {
          const connected = session.status === "WORKING";
          const pending = session.status === "STARTING" || session.status === "SCAN_QR_CODE";
          return (
            <div className="mt-4 grid gap-6 lg:grid-cols-2">
              <Card
                title="Status"
                actions={
                  can("whatsapp.manage") && (
                    <div className="flex gap-2">
                      {!connected && (
                        <Button loading={busy === "connect"} onClick={() => act("connect")}>
                          {session.status === "NOT_CONNECTED" ? "Connect" : "Reconnect"}
                        </Button>
                      )}
                      {session.status !== "NOT_CONNECTED" && (
                        <Button variant="danger" loading={busy === "disconnect"} onClick={() => act("disconnect")}>
                          Disconnect
                        </Button>
                      )}
                    </div>
                  )
                }
              >
                <DetailList
                  items={[
                    ["Status", <Badge key="s" value={session.status} />],
                    ["Session", <span key="n" className="font-mono">{session.session_name}</span>],
                    ["Phone", session.phone_number],
                    ["Last checked", formatDateTime(session.last_status_at)],
                    ["Provider", provider === "mock" ? "Mock (no real messages)" : "WAHA"],
                  ]}
                />
                {provider === "mock" && (
                  <p className="mt-4 text-xs text-amber-700">
                    The backend runs with the mock WhatsApp provider. Sessions connect automatically and messages are only logged, never delivered.
                  </p>
                )}
              </Card>
              {pending && can("whatsapp.manage") && <QRCard />}
              {connected && can("whatsapp.manage") && <TestMessageCard />}
            </div>
          );
        }}
      </QueryState>
    </>
  );
}

function QRCard() {
  const qr = useGet<QRCode>("/gym/whatsapp/qr", undefined, { refetchInterval: 15_000, retry: false });
  return (
    <Card title="Scan QR code">
      <p className="mb-3 text-sm text-slate-600">On the gym's phone open WhatsApp → Settings → Linked devices → Link a device, then scan this code.</p>
      <QueryState query={qr}>
        {(code) => (
          <img src={`data:${code.mimetype};base64,${code.data}`} alt="WhatsApp QR code" className="mx-auto h-64 w-64 rounded-md ring-1 ring-slate-200" />
        )}
      </QueryState>
    </Card>
  );
}

function TestMessageCard() {
  const [phone, setPhone] = useState("");
  const [text, setText] = useState("");
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [result, setResult] = useState<MessageLog | null>(null);

  const send = async (e: FormEvent) => {
    e.preventDefault();
    setBusy(true);
    setError(null);
    setResult(null);
    try {
      const { data } = await api.post<MessageLog>("/gym/whatsapp/test-message", { phone, text });
      setResult(data);
    } catch (err) {
      setError(errorMessage(err));
    } finally {
      setBusy(false);
    }
  };

  return (
    <Card title="Send a test message">
      <form onSubmit={send} className="space-y-4">
        <FormError message={error} />
        {result && (
          <p className={`rounded-md px-3 py-2 text-sm ${result.status === "SENT" ? "bg-emerald-50 text-emerald-700" : "bg-rose-50 text-rose-700"}`}>
            {result.status === "SENT" ? `Sent to ${result.recipient_phone}.` : `Failed: ${result.error}`}
          </p>
        )}
        <Input label="Phone number" required value={phone} onChange={(e) => setPhone(e.target.value)} hint="Your own number. Include the country code or use a 10-digit number." />
        <Textarea label="Message (optional)" value={text} onChange={(e) => setText(e.target.value)} />
        <Button type="submit" loading={busy}>
          Send test
        </Button>
      </form>
    </Card>
  );
}
