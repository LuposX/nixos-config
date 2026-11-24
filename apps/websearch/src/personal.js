// Personalized results, Kagi "website info" style.
//
// Two inputs feed the personal factor of a host:
//   - clicks: every result you open nudges the host's factor up (capped)
//   - explicit keys in the UI: b = block, B = boost, d = downrank
//
// State lives in $WEBSEARCH_STATE_DIR/personal.json so it survives restarts.

import { readFile, writeFile, rename } from "node:fs/promises";
import path from "node:path";
import { config } from "./config.js";
import { normalizeHost } from "./util.js";

const CLICK_STEP = 0.1;
const CLICK_CAP = 0.8;

const file = () => path.join(config.stateDir, "personal.json");
let cache = null;

function empty() {
  return { boost: {}, downrank: {}, block: [] };
}

export async function load() {
  if (cache) return cache;
  try {
    cache = JSON.parse(await readFile(file(), "utf8"));
  } catch {
    cache = empty();
  }
  // Defensive normalization after hand edits.
  const clean = empty();
  for (const [h, v] of Object.entries(cache.boost || {})) {
    if (v && typeof v === "object") clean.boost[normalizeHost(h)] = { factor: Number(v.factor) || 1, n: Number(v.n) || 0 };
  }
  for (const [h, v] of Object.entries(cache.downrank || {})) {
    if (v && typeof v === "object") clean.downrank[normalizeHost(h)] = { factor: Number(v.factor) || 1, n: Number(v.n) || 0 };
  }
  clean.block = (Array.isArray(cache.block) ? cache.block : []).map(normalizeHost).filter(Boolean);
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
  return p.block.includes(host);
}

export function factorFor(p, host) {
  let f = 1;
  const b = p.boost[host];
  if (b) f *= b.factor;
  const d = p.downrank[host];
  if (d) f *= d.factor;
  return f;
}

export function sourceFor(p, host) {
  const parts = [];
  const b = p.boost[host];
  if (b) parts.push(`boost ${b.factor.toFixed(2)} (${b.n} click${b.n === 1 ? "" : "s"})`);
  const d = p.downrank[host];
  if (d) parts.push(`downrank ${d.factor.toFixed(2)} (${d.n} skip${d.n === 1 ? "" : "s"})`);
  if (p.block.includes(host)) parts.push("blocked");
  return parts.join(", ") || "neutral";
}

export async function click(host) {
  const p = await load();
  const h = normalizeHost(host);
  if (!h) return;
  const b = p.boost[h] || (p.boost[h] = { factor: 1, n: 0 });
  b.n += 1;
  b.factor = Number((1 + Math.min(CLICK_CAP, CLICK_STEP * b.n)).toFixed(2));
  await persist(p);
}

export async function apply(action, host) {
  const p = await load();
  const h = normalizeHost(host);
  if (!h || !action) return { ok: false };

  switch (action) {
    case "click":
      await click(h);
      return { ok: true };
    case "block":
      if (!p.block.includes(h)) p.block.push(h);
      delete p.boost[h];
      delete p.downrank[h];
      break;
    case "unblock":
      p.block = p.block.filter((x) => x !== h);
      break;
    case "boost": {
      const prev = p.boost[h] || { factor: 1, n: 0 };
      p.boost[h] = { factor: Number((Math.min(2.5, (prev.factor || 1) + 0.25)).toFixed(2)), n: prev.n };
      delete p.downrank[h];
      break;
    }
    case "unboost":
      delete p.boost[h];
      break;
    case "downrank": {
      const prev = p.downrank[h] || { factor: 1, n: 0 };
      p.downrank[h] = { factor: Number((Math.max(0.2, (prev.factor || 1) - 0.2)).toFixed(2)), n: prev.n };
      delete p.boost[h];
      break;
    }
    case "undownrank":
      delete p.downrank[h];
      break;
    case "reset":
      delete p.boost[h];
      delete p.downrank[h];
      p.block = p.block.filter((x) => x !== h);
      break;
    default:
      return { ok: false };
  }
  await persist(p);
  return { ok: true };
}
