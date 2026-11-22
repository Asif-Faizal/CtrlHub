import { useState } from "react";
import { Link, useParams } from "react-router";
import { api, errorMessage } from "../../api/client";
import { useGet, useInvalidate } from "../../api/hooks";
import type { Attendance, Member, Membership, Page, Payment } from "../../api/types";
import { useAuth } from "../../auth/AuthContext";
import { Can } from "../../auth/guards";
import { Badge, Button, Card, DetailList, FormError, PageHeader, QueryState, Table } from "../../components/ui";
import { AssignMembershipModal, RecordPaymentModal, RenewMembershipModal } from "../../components/MembershipModals";
import { formatDate, formatDateTime, formatMoney, humanize } from "../../lib/format";

export function MemberProfilePage() {
  const { id = "" } = useParams();
  const query = useGet<Member>(`/gym/members/${id}`);
  return <QueryState query={query}>{(m) => <Profile member={m} />}</QueryState>;
}

function Profile({ member }: { member: Member }) {
  const { can } = useAuth();
  const invalidate = useInvalidate();
  const [assigning, setAssigning] = useState(false);
  const [renewing, setRenewing] = useState<Membership | null>(null);
  const [paying, setPaying] = useState<string | null | undefined>(undefined);
  const [error, setError] = useState<string | null>(null);

  const checkIn = async () => {
    setError(null);
    try {
      await api.post("/gym/attendance", { member_id: member.id });
      await invalidate("/gym/attendance", `/gym/members/${member.id}`, "/gym/reports");
    } catch (err) {
      setError(errorMessage(err));
    }
  };

  return (
    <>
      <PageHeader
        title={member.full_name}
        subtitle={member.current_plan ? `${member.current_plan} · expires ${formatDate(member.expires_on)}` : "No current membership"}
        actions={
          <>
            <Can perm="attendance.write">
              <Button variant="secondary" onClick={checkIn}>
                Check in today
              </Button>
            </Can>
            <Can perm="members.write">
              <Link to={`/gym/members/${member.id}/edit`} className="rounded-md bg-white px-3.5 py-2 text-sm font-medium text-slate-700 ring-1 ring-slate-300 hover:bg-slate-50">
                Edit
              </Link>
            </Can>
          </>
        }
      />
      <FormError message={error} />
      <div className="mt-4 grid gap-6 lg:grid-cols-3">
        <Card title="Profile" className="lg:col-span-2">
          <DetailList
            items={[
              ["Membership", <Badge key="m" value={member.membership_status} />],
              ["Phone", member.phone],
              ["Email", member.email],
              ["Gender", member.gender ? humanize(member.gender) : ""],
              ["Date of birth", formatDate(member.date_of_birth)],
              ["Joined", formatDate(member.joined_on)],
              ["Address", member.address],
              ["Emergency contact", member.emergency_contact],
              ["Member status", <Badge key="s" value={member.status} />],
              ["Notes", member.notes],
            ]}
          />
        </Card>
        <Card title="WhatsApp consent">
          <DetailList
            items={[
              ["Reminders", member.whatsapp_opt_in ? "Opted in" : "Not opted in"],
              ["Promotions", member.marketing_opt_in ? "Opted in" : "Not opted in"],
            ]}
          />
        </Card>
      </div>
      {can("memberships.read") && (
        <Card
          title="Memberships"
          className="mt-6"
          actions={
            <Can perm="memberships.write">
              <Button size="sm" onClick={() => setAssigning(true)}>
                Assign membership
              </Button>
            </Can>
          }
        >
          <MembershipHistory memberId={member.id} onRenew={setRenewing} onPay={(id) => setPaying(id)} />
        </Card>
      )}
      {can("payments.read") && (
        <Card
          title="Payments"
          className="mt-6"
          actions={
            <Can perm="payments.write">
              <Button size="sm" variant="secondary" onClick={() => setPaying(null)}>
                Record payment
              </Button>
            </Can>
          }
        >
          <PaymentHistory memberId={member.id} />
        </Card>
      )}
      {can("attendance.read") && (
        <Card title="Attendance" className="mt-6">
          <AttendanceHistory memberId={member.id} />
        </Card>
      )}
      {assigning && <AssignMembershipModal memberId={member.id} onClose={() => setAssigning(false)} />}
      {renewing && <RenewMembershipModal membership={{ ...renewing, member_name: member.full_name }} onClose={() => setRenewing(null)} />}
      {paying !== undefined && <RecordPaymentModal memberId={member.id} membershipId={paying ?? undefined} onClose={() => setPaying(undefined)} />}
    </>
  );
}

function MembershipHistory({ memberId, onRenew, onPay }: { memberId: string; onRenew: (m: Membership) => void; onPay: (id: string) => void }) {
  const { can } = useAuth();
  const query = useGet<Page<Membership>>(`/gym/members/${memberId}/memberships`);
  return (
    <QueryState query={query} isEmpty={(p) => p.items.length === 0} emptyMessage="No memberships yet.">
      {(p) => {
        const latest = p.items.find((m) => m.status !== "CANCELLED");
        return (
          <Table
            rows={p.items}
            rowKey={(m) => m.id}
            columns={[
              { header: "Plan", cell: (m) => m.plan_name },
              { header: "Period", cell: (m) => `${formatDate(m.start_date)} – ${formatDate(m.end_date)}` },
              { header: "Status", cell: (m) => <Badge value={m.status} /> },
              { header: "Total", cell: (m) => formatMoney(m.total_amount_minor) },
              { header: "Paid", cell: (m) => formatMoney(m.paid_amount_minor) },
              { header: "Pending", cell: (m) => (m.pending_amount_minor > 0 ? <span className="text-rose-600">{formatMoney(m.pending_amount_minor)}</span> : "—") },
              { header: "Payment", cell: (m) => <Badge value={m.payment_status} /> },
              {
                header: "",
                className: "text-right",
                cell: (m) => (
                  <div className="flex justify-end gap-1">
                    {can("payments.write") && m.pending_amount_minor > 0 && m.status !== "CANCELLED" && (
                      <Button size="sm" variant="ghost" onClick={() => onPay(m.id)}>
                        Pay
                      </Button>
                    )}
                    {can("memberships.write") && latest?.id === m.id && (
                      <Button size="sm" variant="ghost" onClick={() => onRenew(m)}>
                        Renew
                      </Button>
                    )}
                  </div>
                ),
              },
            ]}
          />
        );
      }}
    </QueryState>
  );
}

function PaymentHistory({ memberId }: { memberId: string }) {
  const query = useGet<Page<Payment>>(`/gym/members/${memberId}/payments`);
  return (
    <QueryState query={query} isEmpty={(p) => p.items.length === 0} emptyMessage="No payments recorded.">
      {(p) => (
        <Table
          rows={p.items}
          rowKey={(x) => x.id}
          columns={[
            { header: "Date", cell: (x) => formatDateTime(x.paid_at) },
            { header: "Amount", cell: (x) => formatMoney(x.amount_minor) },
            { header: "Method", cell: (x) => humanize(x.method) },
            { header: "Reference", cell: (x) => x.reference || "—" },
          ]}
        />
      )}
    </QueryState>
  );
}

function AttendanceHistory({ memberId }: { memberId: string }) {
  const query = useGet<Attendance[]>(`/gym/members/${memberId}/attendance`);
  return (
    <QueryState query={query} isEmpty={(l) => (l ?? []).length === 0} emptyMessage="No check-ins recorded.">
      {(list) => (
        <Table
          rows={list.slice(0, 30)}
          rowKey={(a) => a.id}
          columns={[
            { header: "Date", cell: (a) => formatDate(a.attendance_date) },
            { header: "Checked in", cell: (a) => formatDateTime(a.check_in_at) },
          ]}
        />
      )}
    </QueryState>
  );
}
