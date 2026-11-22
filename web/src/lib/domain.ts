import type { Campaign, CampaignAudience } from "../api/types";
import { humanize } from "./format";

// Opening hours are stored as JSON; the UI edits a free-text summary.
export function openingHoursText(value: unknown): string {
  if (value && typeof value === "object" && "summary" in value) return String((value as { summary: unknown }).summary ?? "");
  return "";
}

export function openingHoursJSON(text: string): unknown {
  return text.trim() ? { summary: text.trim() } : null;
}

export const audiences: { value: CampaignAudience; label: string }[] = [
  { value: "ACTIVE_MEMBERS", label: "Active members" },
  { value: "EXPIRED_MEMBERS", label: "Expired members" },
  { value: "EXPIRING_SOON", label: "Members expiring soon" },
  { value: "NEW_LEADS", label: "New leads" },
  { value: "SELECTED_MEMBERS", label: "Selected members" },
];

export function audienceLabel(c: Campaign): string {
  const base = audiences.find((a) => a.value === c.audience)?.label ?? humanize(c.audience);
  if (c.audience === "EXPIRING_SOON") return `${base} (${c.audience_params.expiring_in_days ?? 7} days)`;
  if (c.audience === "NEW_LEADS") return `${base} (last ${c.audience_params.leads_created_days ?? 30} days)`;
  if (c.audience === "SELECTED_MEMBERS") return `${base} (${c.audience_params.member_ids?.length ?? 0})`;
  return base;
}
