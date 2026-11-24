// Snaps: pinned queries and URLs shown above the results.
// Stored in $WEBSEARCH_STATE_DIR/snaps.json.

import { readFile, writeFile, rename } from "node:fs/promises";
import path from "node:path";
import { config } from "./config.js";

const file = () => path.join(config.stateDir, "snaps.json");
let cache = null;

export async function load() {
  if (cache) return cache;
  try {
    cache = JSON.parse(await readFile(file(), "utf8"));
  } catch {
    cache = [];
  }
  if (!Array.isArray(cache)) cache = [];
  return cache;
}

async function persist(snaps) {
  cache = snaps;
  const tmp = `${file()}.tmp`;
  await writeFile(tmp, JSON.stringify(snaps, null, 2));
  await rename(tmp, file());
}

export async function add({ name, query, url }) {
  const snaps = await load();
  const id = Date.now().toString(36) + Math.random().toString(36).slice(2, 6);
  snaps.push({ id, name: String(name || query || url).slice(0, 80), query: query ? String(query) : null, url: url ? String(url) : null });
  await persist(snaps);
  return snaps;
}

export async function remove(id) {
  const snaps = await load();
  await persist(snaps.filter((s) => s.id !== id));
  return snaps;
}
