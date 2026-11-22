// Money is stored in minor units (paise for INR) as integers.

export function formatMoney(minor: number, currency = "INR"): string {
  return new Intl.NumberFormat("en-IN", { style: "currency", currency, minimumFractionDigits: 0, maximumFractionDigits: 2 }).format(
    minor / 100,
  );
}

// toMinor parses a user-entered major amount ("1499.50") into minor units.
// Returns null for anything that is not a non-negative amount with at most two
// decimals.
export function toMinor(input: string): number | null {
  const s = input.trim().replace(/,/g, "");
  if (!/^\d+(\.\d{1,2})?$/.test(s)) return null;
  const [whole, frac = ""] = s.split(".");
  return Number(whole) * 100 + Number(frac.padEnd(2, "0"));
}

export function fromMinor(minor: number): string {
  return (minor / 100).toFixed(minor % 100 === 0 ? 0 : 2);
}

export function formatDate(value: string | null | undefined): string {
  if (!value) return "—";
  const [y, m, d] = value.slice(0, 10).split("-").map(Number);
  if (!y || !m || !d) return value;
  return new Date(Date.UTC(y, m - 1, d)).toLocaleDateString("en-IN", {
    day: "2-digit",
    month: "short",
    year: "numeric",
    timeZone: "UTC",
  });
}

export function formatDateTime(value: string | null | undefined): string {
  if (!value) return "—";
  return new Date(value).toLocaleString("en-IN", { dateStyle: "medium", timeStyle: "short" });
}

export function todayISO(): string {
  const d = new Date();
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}-${String(d.getDate()).padStart(2, "0")}`;
}

export function humanize(value: string): string {
  return value
    .toLowerCase()
    .split("_")
    .map((w) => w.charAt(0).toUpperCase() + w.slice(1))
    .join(" ");
}

export function parseDays(input: string): number[] | null {
  if (input.trim() === "") return [];
  const parts = input.split(",").map((p) => p.trim());
  const days = parts.map(Number);
  if (days.some((d, i) => parts[i] === "" || !Number.isInteger(d) || d < 0)) return null;
  return [...new Set(days)].sort((a, b) => b - a);
}
