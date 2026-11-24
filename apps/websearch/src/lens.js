import { readdir, readFile } from "node:fs/promises";
import path from "node:path";
import { config } from "./config.js";
import { normalizeHost, hostMatches } from "./util.js";

export async function listLenses() {
  try {
    const files = await readdir(config.lensDir);
    return files.filter((f) => f.endsWith(".json")).map((f) => f.replace(/\.json$/, ""));
  } catch {
    return ["default"];
  }
}

export async function loadLens(name) {
  const safe = String(name || config.defaultLens).replace(/[^a-zA-Z0-9_-]/g, "");
  if (!safe) return normalizeLens({ name: "default" });
  try {
    const text = await readFile(path.join(config.lensDir, `${safe}.json`), "utf8");
    return normalizeLens(JSON.parse(text));
  } catch {
    return normalizeLens({ name: safe });
  }
}

export function normalizeLens(data) {
  const block = new Set((data.block || []).map(normalizeHost).filter(Boolean));
  const boost = new Map();
  for (const item of data.boost || []) {
    if (typeof item === "string") boost.set(normalizeHost(item), 1.5);
    else if (item && item.host) boost.set(normalizeHost(item.host), Number(item.factor) || 1.5);
  }
  const downrank = new Map();
  for (const item of data.downrank || []) {
    if (typeof item === "string") downrank.set(normalizeHost(item), 0.5);
    else if (item && item.host) downrank.set(normalizeHost(item.host), Number(item.factor) || 0.5);
  }
  return { name: data.name || "default", block, boost, downrank };
}

export function isBlocked(lens, host) {
  if (!host) return false;
  for (const pattern of lens.block) if (hostMatches(host, pattern)) return true;
  return false;
}

export function factorFor(lens, host) {
  if (!host) return 1;
  let f = 1;
  for (const [pattern, value] of lens.boost) if (hostMatches(host, pattern)) f *= value;
  for (const [pattern, value] of lens.downrank) if (hostMatches(host, pattern)) f *= value;
  return f;
}
