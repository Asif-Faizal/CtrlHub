import { useState } from "react";
import { Link } from "react-router";
import { api, errorMessage } from "../../api/client";
import { useGet, useInvalidate } from "../../api/hooks";
import type { Attendance, Member } from "../../api/types";
import { Can } from "../../auth/guards";
import { Button, FormError, Input, Modal, PageHeader, QueryState, Table } from "../../components/ui";
import { formatDateTime, todayISO } from "../../lib/format";
import { MemberPicker } from "./PaymentsPage";

export function AttendancePage() {
  const invalidate = useInvalidate();
  const [date, setDate] = useState(todayISO());
  const [picking, setPicking] = useState(false);
  const [expired, setExpired] = useState<Member | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [notice, setNotice] = useState<string | null>(null);
  const query = useGet<Attendance[]>("/gym/attendance", { date });

  const checkIn = async (m: Member, allowExpired = false) => {
    setError(null);
    setNotice(null);
    try {
      await api.post("/gym/attendance", { member_id: m.id, allow_expired: allowExpired });
      await invalidate("/gym/attendance", "/gym/reports", `/gym/members/${m.id}`);
      setNotice(`${m.full_name} checked in.`);
      setExpired(null);
    } catch (err) {
      const msg = errorMessage(err);
      if (!allowExpired && /membership/i.test(msg)) setExpired(m);
      else setError(msg);
    }
  };

  return (
    <>
      <PageHeader
        title="Attendance"
        actions={
          <Can perm="attendance.write">
            <Button onClick={() => setPicking(true)}>Check in member</Button>
          </Can>
        }
      />
      <div className="mb-4 w-44">
        <Input label="Date" type="date" value={date} onChange={(e) => setDate(e.target.value)} />
      </div>
      <FormError message={error} />
      {notice && <p className="mb-4 rounded-md bg-emerald-50 px-3 py-2 text-sm text-emerald-700">{notice}</p>}
      <QueryState query={query} isEmpty={(l) => (l ?? []).length === 0} emptyMessage="No check-ins for this date.">
        {(list) => (
          <>
            <p className="mb-2 text-sm text-slate-600">{list.length} check-ins</p>
            <Table
              rows={list}
              rowKey={(a) => a.id}
              columns={[
                { header: "Member", cell: (a) => <Link className="text-indigo-600" to={`/gym/members/${a.member_id}`}>{a.member_name}</Link> },
                { header: "Checked in", cell: (a) => formatDateTime(a.check_in_at) },
              ]}
            />
          </>
        )}
      </QueryState>
      {picking && (
        <MemberPicker
          title="Check in member"
          onClose={() => setPicking(false)}
          onPick={(m) => {
            setPicking(false);
            checkIn(m);
          }}
        />
      )}
      {expired && (
        <Modal
          open
          title="No active membership"
          onClose={() => setExpired(null)}
          footer={
            <>
              <Button variant="secondary" onClick={() => setExpired(null)}>
                Cancel
              </Button>
              <Button onClick={() => checkIn(expired, true)}>Check in anyway</Button>
            </>
          }
        >
          <p className="text-sm text-slate-600">{expired.full_name} does not have an active membership today. Record the visit anyway?</p>
        </Modal>
      )}
    </>
  );
}
