import { describe, expect, it } from "vitest";
import { formatDate, fromMinor, humanize, parseDays, toMinor } from "./format";

describe("toMinor", () => {
  it("parses whole and decimal amounts into minor units", () => {
    expect(toMinor("1499")).toBe(149900);
    expect(toMinor("1499.5")).toBe(149950);
    expect(toMinor("1,499.05")).toBe(149905);
    expect(toMinor("0")).toBe(0);
  });

  it("rejects invalid amounts", () => {
    expect(toMinor("")).toBeNull();
    expect(toMinor("-5")).toBeNull();
    expect(toMinor("12.345")).toBeNull();
    expect(toMinor("abc")).toBeNull();
  });

  it("round-trips through fromMinor", () => {
    expect(fromMinor(149900)).toBe("1499");
    expect(fromMinor(149950)).toBe("1499.50");
    expect(toMinor(fromMinor(149950))).toBe(149950);
  });
});

describe("parseDays", () => {
  it("dedupes and sorts descending", () => {
    expect(parseDays("1, 7,3,7, 0")).toEqual([7, 3, 1, 0]);
    expect(parseDays("")).toEqual([]);
  });

  it("rejects non-integers and negatives", () => {
    expect(parseDays("1, x")).toBeNull();
    expect(parseDays("-1")).toBeNull();
    expect(parseDays("1,,2")).toBeNull();
  });
});

describe("formatting", () => {
  it("formats calendar dates without timezone drift", () => {
    expect(formatDate("2026-01-31")).toContain("2026");
    expect(formatDate("2026-01-31")).toContain("31");
    expect(formatDate(null)).toBe("—");
  });

  it("humanizes enum values", () => {
    expect(humanize("PENDING_APPROVAL")).toBe("Pending Approval");
  });
});
