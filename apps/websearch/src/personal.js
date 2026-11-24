// Personalized results, Kagi "website info" style.
//
// Each host gets one of five levels (like Kagi's site info modal):
//   block   — filtered out entirely
//   lower   — factor 0.5
//   default — factor 1 (neutral)
//   raise   — factor 1.5
//   pin     — factor 2.5
// Hosts with no explicit level ("auto") earn a small boost from your
// clicks: +0.1 per click, capped at +0.8.
//
// State lives in $WEBSEARCH_STATE_DIR/personal.json.

import { readFile, writeFile, rename } from "node:fs/promises";
import path from "node:path";
import { config } from "./config.js";
import { normalizeHost } from "./util.js";

const CLICK_STEP = 0.1;
const CLICK_CAP = 0.8;
export const LEVEL_FACTOR = { block: 0, lower: 0.5, default: 1, raise: 1.5, pin: 2.5 };

const file = () => path.join(config.stateDir, "personal.json");
let cache = null;

// Rules apply at registrable-domain level, Kagi-style: lowering
// en.wikipedia.org covers de.wikipedia.org too. Heuristic PSL: treat
// two-label domains as registrable unless the second-level label is a
// common prefix of a two-part TLD (co.uk, com.au, ...).
const MULTIPART_TLD = new Set(["co", "com", "net", "org", "gov", "ac", "edu"]);
export function baseDomain(host) {
  const parts = String(host || "").toLowerCase().split(".").filter(Boolean);
  if (parts.length <= 2) return parts.join(".");
  const snd = parts[parts.length - 2];
  if (MULTIPART_TLD.has(snd) && parts[parts.length - 1].length === 2) return parts.slice(-3).join(".");
  return parts.slice(-2).join(".");
}

function empty() {
  return { sites: {} };
}

function normalizeEntry(v) {
  if (!v || typeof v !== "object") return { level: "auto", n: 0 };
  const level = ["block", "lower", "default", "raise", "pin", "auto"].includes(v.level) ? v.level : "auto";
  return { level, n: Number(v.n) || 0 };
}

export async function load() {
  if (cache) return cache;
  try {
    cache = JSON.parse(await readFile(file(), "utf8"));
  } catch {
    cache = empty();
  }
  const clean = empty();
  if (cache.sites && typeof cache.sites === "object") {
    for (const [h, v] of Object.entries(cache.sites)) {
      clean.sites[baseDomain(normalizeHost(h))] = normalizeEntry(v);
    }
  } else {
    // Migrate the v1 format {boost, downrank, block}.
    for (const h of cache.block || []) clean.sites[baseDomain(normalizeHost(h))] = { level: "block", n: 0 };
    for (const [h, v] of Object.entries(cache.boost || {})) {
      if (v && Number(v.factor) > 1) clean.sites[baseDomain(normalizeHost(h))] = { level: "raise", n: Number(v.n) || 0 };
      else clean.sites[baseDomain(normalizeHost(h))] = { level: "auto", n: Number(v?.n) || 0 };
    }
    for (const [h, v] of Object.entries(cache.downrank || {})) {
      if (v && Number(v.factor) < 1) clean.sites[baseDomain(normalizeHost(h))] = { level: "lower", n: Number(v.n) || 0 };
    }
  }
  cache = clean;
  return cache;
}

async function persist(data) {
  cache = data;
  const tmp = `${file()}.tmp`;
  await writeFile(tmp, JSON.stringify(data, null, 2));
  await rename(tmp, file());
}

export function isBlocked(p, host) {
  return p.sites[baseDomain(host)]?.level === "block";
}

export function factorFor(p, host) {
  const s = p.sites[baseDomain(host)];
  if (!s) return 1;
  if (s.level !== "auto") return LEVEL_FACTOR[s.level];
  return Number((1 + Math.min(CLICK_CAP, CLICK_STEP * s.n)).toFixed(2));
}

export function levelOf(p, host) {
  return p.sites[baseDomain(host)]?.level || "auto";
}

export function sourceFor(p, host) {
  const s = p.sites[baseDomain(host)];
  if (!s) return "neutral (auto)";
  if (s.level === "block") return "blocked";
  if (s.level === "lower") return "lowered — fewer results from this domain";
  if (s.level === "raise") return "raised — more results from this domain";
  if (s.level === "pin") return "pinned — strongly boosted";
  if (s.level === "default") return "default (manually set to neutral)";
  return s.n ? `auto boost ×${factorFor(p, host).toFixed(2)} (${s.n} clicks)` : "neutral (auto)";
}

export async function click(host) {
  const p = await load();
  const h = baseDomain(normalizeHost(host));
  if (!h) return;
  const s = p.sites[h] || (p.sites[h] = { level: "auto", n: 0 });
  s.n += 1;
  await persist(p);
}

export async function apply(action, host) {
  const p = await load();
  const h = baseDomain(normalizeHost(host));
  if (!h || !action) return { ok: false };

  switch (action) {
    case "click":
      await click(h);
      return { ok: true };
    case "block": case "lower": case "raise": case "pin": {
      const s = p.sites[h] || (p.sites[h] = { level: "auto", n: 0 });
      s.level = action;
      break;
    }
    case "default": case "reset": case "unblock": case "unboost": case "undownrank": {
      const s = p.sites[h];
      if (s) { s.level = "auto"; s.n = 0; }
      break;
    }
    default:
      return { ok: false };
  }
  await persist(p);
  return { ok: true };
}
