// DuckDuckGo-style bangs. The full DDG bang list (~12k entries) is fetched
// once, cached in $WEBSEARCH_STATE_DIR/bangs.json, and refreshed weekly.
// A small built-in fallback covers the common ones when offline.

import { stat, readFile, writeFile, rename } from "node:fs/promises";
import path from "node:path";
import { config } from "./config.js";

const WEEK = 7 * 86400e3;

const BUILTIN = [
  { phrases: ["g"], name: "Google", url_format: "https://www.google.com/search?q={{{s}}}" },
  { phrases: ["d"], name: "DuckDuckGo", url_format: "https://duckduckgo.com/?q={{{s}}}" },
  { phrases: ["b"], name: "Bing", url_format: "https://www.bing.com/search?q={{{s}}}" },
  { phrases: ["w"], name: "Wikipedia", url_format: "https://en.wikipedia.org/wiki/Special:Search?search={{{s}}}" },
  { phrases: ["gh"], name: "GitHub", url_format: "https://github.com/search?q={{{s}}}" },
  { phrases: ["so"], name: "Stack Overflow", url_format: "https://stackoverflow.com/search?q={{{s}}}" },
  { phrases: ["yt"], name: "YouTube", url_format: "https://www.youtube.com/results?search_query={{{s}}}" },
  { phrases: ["md"], name: "MDN", url_format: "https://developer.mozilla.org/en-US/search?q={{{s}}}" },
  { phrases: ["aw"], name: "Arch Wiki", url_format: "https://wiki.archlinux.org/index.php?search={{{s}}}" },
  { phrases: ["hn"], name: "Hacker News", url_format: "https://hn.algolia.com/?q={{{s}}}" },
  { phrases: ["r"], name: "Reddit", url_format: "https://www.reddit.com/search/?q={{{s}}}" },
  { phrases: ["ar"], name: "arXiv", url_format: "https://arxiv.org/abs/{{{s}}}" },
  { phrases: ["se"], name: "Stack Exchange", url_format: "https://stackexchange.com/search?q={{{s}}}" },
  { phrases: ["nixos"], name: "NixOS options", url_format: "https://search.nixos.org/options?query={{{s}}}" },
  { phrases: ["mn"], name: "Man pages", url_format: "https://man.archlinux.org/search?q={{{s}}}" },
];

const file = () => path.join(config.stateDir, "bangs.json");
let cache = null;
let loadedAt = 0;

async function loadCache() {
  if (cache && Date.now() - loadedAt < WEEK) return cache;
  try {
    const st = await stat(file());
    if (Date.now() - st.mtimeMs < WEEK) {
      cache = JSON.parse(await readFile(file(), "utf8"));
      loadedAt = Date.now();
      return cache;
    }
  } catch {
    /* no cache yet */
  }
  try {
    const res = await fetch("https://duckduckgo.com/bang.js", {
      headers: { "User-Agent": config.userAgent },
      signal: AbortSignal.timeout(15000),
    });
    if (res.ok) {
      const list = await res.json();
      if (Array.isArray(list) && list.length > 1000) {
        const tmp = `${file()}.tmp`;
        await writeFile(tmp, JSON.stringify(list));
        await rename(tmp, file());
        cache = list;
        loadedAt = Date.now();
        return cache;
      }
    }
  } catch {
    /* offline: fall back */
  }
  cache = BUILTIN;
  loadedAt = Date.now();
  return cache;
}

export async function resolveBang(rawQuery) {
  const m = String(rawQuery || "").match(/^\s*!([a-z0-9_-]+)\s*(.*)$/i);
  if (!m) return null;
  const token = m[1].toLowerCase();
  const rest = (m[2] || "").trim();
  const list = await loadCache();
  // DDG bang.js schema: t = trigger, u = URL template, s = name.
  // Accept the documented `phrases` / `url_format` shape too.
  const entry = list.find((e) =>
    (e.t ? [e.t] : e.phrases || []).some((p) => String(p).replace(/^!/, "").toLowerCase() === token),
  );
  if (!entry) return null;
  const template = entry.u || entry.url_format || entry.url;
  if (!template) return null;
  const enc = encodeURIComponent(rest);
  let url = template.replace(/\{\{\{s\}\}\}/g, enc);
  if (!/\{\{\{s\}\}\}/.test(template) && rest) url = `${template}${template.endsWith("/") ? "" : "/"}${enc}`;
  return { url, name: entry.name, bang: token, rest };
}

export async function bangCount() {
  const list = await loadCache();
  return list.length;
}
