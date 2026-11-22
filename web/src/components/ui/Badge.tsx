import { humanize } from "../../lib/format";

type Tone = "green" | "amber" | "red" | "slate" | "blue";

const tones: Record<Tone, string> = {
  green: "bg-emerald-50 text-emerald-700 ring-emerald-200",
  amber: "bg-amber-50 text-amber-700 ring-amber-200",
  red: "bg-rose-50 text-rose-700 ring-rose-200",
  slate: "bg-slate-100 text-slate-600 ring-slate-200",
  blue: "bg-sky-50 text-sky-700 ring-sky-200",
};

const statusTones: Record<string, Tone> = {
  ACTIVE: "green",
  PAID: "green",
  SENT: "green",
  WORKING: "green",
  COMPLETED: "green",
  APPROVED: "blue",
  CONVERTED: "green",
  UPCOMING: "blue",
  SENDING: "blue",
  STARTING: "blue",
  CONTACTED: "blue",
  NEW: "blue",
  PARTIAL: "amber",
  PENDING: "amber",
  PENDING_SETUP: "amber",
  PENDING_APPROVAL: "amber",
  SCAN_QR_CODE: "amber",
  DRAFT: "slate",
  NONE: "slate",
  STOPPED: "slate",
  NOT_CONNECTED: "slate",
  SKIPPED: "slate",
  CANCELLED: "slate",
  INACTIVE: "slate",
  LOST: "slate",
  EXPIRED: "red",
  UNPAID: "red",
  FAILED: "red",
  REJECTED: "red",
};

export function Badge({ value, tone }: { value: string; tone?: Tone }) {
  const t = tone ?? statusTones[value] ?? "slate";
  return <span className={`inline-flex rounded-full px-2 py-0.5 text-xs font-medium ring-1 ${tones[t]}`}>{humanize(value)}</span>;
}
