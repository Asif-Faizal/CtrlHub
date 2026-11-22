import { useState } from "react";
import { useParams } from "react-router";
import { api, errorMessage } from "../../api/client";
import { useGet, useInvalidate } from "../../api/hooks";
import type { Campaign, CampaignRecipient } from "../../api/types";
import { useAuth } from "../../auth/AuthContext";
import { Badge, Button, Card, DetailList, FormError, Input, Modal, PageHeader, QueryState, Stat, Table } from "../../components/ui";
import { formatDateTime, humanize } from "../../lib/format";
import { CampaignModal } from "./PromotionsPage";
import { audienceLabel } from "../../lib/domain";

export function PromotionDetailPage() {
  const { id = "" } = useParams();
  const query = useGet<Campaign>(`/gym/campaigns/${id}`, undefined, {
    refetchInterval: (q) => (q.state.data?.status === "SENDING" || q.state.data?.status === "APPROVED" ? 10_000 : false),
  });
  return <QueryState query={query}>{(c) => <PromotionDetail campaign={c} />}</QueryState>;
}

function PromotionDetail({ campaign: c }: { campaign: Campaign }) {
  const { can } = useAuth();
  const invalidate = useInvalidate();
  const [editing, setEditing] = useState(false);
  const [rejecting, setRejecting] = useState(false);
  const [reason, setReason] = useState("");
  const [busy, setBusy] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const hasRecipients = ["APPROVED", "SENDING", "COMPLETED", "CANCELLED"].includes(c.status);

  const act = async (action: "submit" | "approve" | "reject" | "cancel", body?: object) => {
    setBusy(action);
    setError(null);
    try {
      await api.post(`/gym/campaigns/${c.id}/${action}`, body);
      await invalidate("/gym/campaigns");
      setRejecting(false);
    } catch (err) {
      setError(errorMessage(err));
    } finally {
      setBusy(null);
    }
  };

  return (
    <>
      <PageHeader
        title={c.name}
        subtitle={audienceLabel(c)}
        actions={
          <>
            {c.status === "DRAFT" && can("campaigns.write") && (
              <>
                <Button variant="secondary" onClick={() => setEditing(true)}>
                  Edit
                </Button>
                <Button loading={busy === "submit"} onClick={() => act("submit")}>
                  Submit for approval
                </Button>
              </>
            )}
            {c.status === "PENDING_APPROVAL" && can("campaigns.approve") && (
              <>
                <Button variant="secondary" onClick={() => setRejecting(true)}>
                  Reject
                </Button>
                <Button loading={busy === "approve"} onClick={() => act("approve")}>
                  Approve
                </Button>
              </>
            )}
            {["DRAFT", "PENDING_APPROVAL", "APPROVED", "SENDING"].includes(c.status) && can("campaigns.write") && (
              <Button variant="danger" loading={busy === "cancel"} onClick={() => window.confirm("Cancel this promotion? Unsent messages will not be sent.") && act("cancel")}>
                Cancel
              </Button>
            )}
          </>
        }
      />
      <FormError message={error} />
      {c.status === "PENDING_APPROVAL" && !can("campaigns.approve") && (
        <p className="mb-4 rounded-md bg-amber-50 px-3 py-2 text-sm text-amber-700">Waiting for a gym administrator or manager to approve.</p>
      )}
      {c.status === "APPROVED" && (
        <p className="mb-4 rounded-md bg-sky-50 px-3 py-2 text-sm text-sky-700">
          Approved. Messages are sent by the scheduled campaign workflow (every 15 minutes), throttled, and only if WhatsApp is connected.
        </p>
      )}
      <div className="grid gap-6 lg:grid-cols-3">
        <Card title="Message" className="lg:col-span-2">
          <p className="whitespace-pre-wrap rounded-md bg-slate-50 p-4 text-sm text-slate-800">{c.message}</p>
        </Card>
        <Card title="Details">
          <DetailList
            items={[
              ["Status", <Badge key="s" value={c.status} />],
              ["Created", formatDateTime(c.created_at)],
              ["Approved", formatDateTime(c.approved_at)],
              ...(c.rejection_reason ? ([["Rejection reason", c.rejection_reason]] as [string, string][]) : []),
            ]}
          />
        </Card>
      </div>
      {hasRecipients && (
        <>
          <div className="mt-6 grid grid-cols-2 gap-4 lg:grid-cols-4">
            <Stat label="Recipients" value={c.recipients_total} />
            <Stat label="Sent" value={c.sent_count} />
            <Stat label="Failed" value={c.failed_count} />
            <Stat label="Skipped" value={c.skipped_count} hint="Consent withdrawn or invalid" />
          </div>
          <Card title="Recipients" className="mt-6">
            <Recipients id={c.id} />
          </Card>
        </>
      )}
      {editing && <CampaignModal campaign={c} onClose={() => setEditing(false)} onSaved={() => undefined} />}
      <Modal
        open={rejecting}
        title="Reject promotion"
        onClose={() => setRejecting(false)}
        footer={
          <>
            <Button variant="secondary" onClick={() => setRejecting(false)}>
              Cancel
            </Button>
            <Button variant="danger" loading={busy === "reject"} onClick={() => act("reject", { reason })}>
              Reject
            </Button>
          </>
        }
      >
        <Input label="Reason (optional)" value={reason} onChange={(e) => setReason(e.target.value)} />
      </Modal>
    </>
  );
}

function Recipients({ id }: { id: string }) {
  const query = useGet<CampaignRecipient[]>(`/gym/campaigns/${id}/recipients`);
  return (
    <QueryState query={query} isEmpty={(l) => (l ?? []).length === 0} emptyMessage="No recipients have opted in to promotions for this audience.">
      {(list) => (
        <Table
          rows={list}
          rowKey={(r) => r.id}
          columns={[
            { header: "Name", cell: (r) => r.name },
            { header: "Phone", cell: (r) => r.phone },
            { header: "Type", cell: (r) => humanize(r.recipient_type) },
            { header: "Status", cell: (r) => <Badge value={r.status} /> },
            { header: "Sent", cell: (r) => formatDateTime(r.sent_at) },
            { header: "Error", cell: (r) => <span className="text-rose-600">{r.error}</span> },
          ]}
        />
      )}
    </QueryState>
  );
}
