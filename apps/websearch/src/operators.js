// Operator syntax, Kagi-style:
//   !gh rust          bang (first token only)
//   site:example.com  require host
//   -site:reddit.com  exclude host
//   lang:de           interface/result language
//   after:2024-01-01  / before:2024-06-01  (dates or relative: 3d, 2w, 6m, 1y, today)
//   filetype:pdf      file type
//   !i !v !n !m !w    internal vertical bangs — switch search tab

const VERTICAL_BANGS = { i: "images", v: "videos", n: "news", m: "maps", w: "general", k: "general" };

function parseWhen(s) {
  const now = Date.now();
  const v = String(s).toLowerCase().trim();
  if (v === "today") return now - 86400e3;
  let m = v.match(/^(\d+)\s*([dwm])$/);
  if (m) {
    const n = Number(m[1]);
    const mult = { d: 86400e3, w: 7 * 86400e3, m: 31 * 86400e3, y: 365 * 86400e3 }[m[2]];
    return now - n * mult;
  }
  m = v.match(/^(\d{4})-(\d{2})-(\d{2})$/);
  if (m) return Date.parse(`${m[1]}-${m[2]}-${m[3]}T00:00:00Z`) || null;
  return null;
}

function timeRangeFor(after, before) {
  // SearXNG only supports coarse buckets; pick the smallest bucket that covers `after`.
  const t = after ? parseWhen(after) : null;
  if (t == null) return null;
  const d = Date.now() - t;
  if (d <= 86400e3 * 1.5) return "day";
  if (d <= 86400e3 * 8) return "week";
  if (d <= 86400e3 * 32) return "month";
  if (d <= 86400e3 * 370) return "year";
  return null;
}

export function parseQuery(raw) {
  const out = {
    bang: null,
    language: null,
    timeRange: null,
    sites: [],
    notSites: [],
    filetype: null,
    chips: [],
  };
  const keep = [];
  for (const tok of String(raw || "").split(/\s+/)) {
    if (!tok) continue;
    let m;
    if ((m = tok.match(/^!([a-z0-9_-]+)$/i))) {
      const b = m[1].toLowerCase();
      if (out.bang === null) {
        if (VERTICAL_BANGS[b]) {
          out.vertical = VERTICAL_BANGS[b];
          out.chips.push({ kind: "vertical", label: tok, raw: tok });
        } else {
          out.bang = b;
          out.chips.push({ kind: "bang", label: tok, raw: tok });
        }
      } else {
        keep.push(tok);
      }
      continue;
    }
    if ((m = tok.match(/^site:(.+)$/i))) {
      out.sites.push(m[1]);
      out.chips.push({ kind: "site", label: tok, raw: tok });
      continue;
    }
    if ((m = tok.match(/^-site:(.+)$/i))) {
      out.notSites.push(m[1]);
      out.chips.push({ kind: "notsite", label: tok, raw: tok });
      continue;
    }
    if ((m = tok.match(/^lang:([a-zA-Z-]+)$/))) {
      out.language = m[1];
      out.chips.push({ kind: "lang", label: tok, raw: tok });
      continue;
    }
    if ((m = tok.match(/^before:(\S+)$/i))) {
      out.before = m[1];
      out.chips.push({ kind: "before", label: tok, raw: tok });
      continue;
    }
    if ((m = tok.match(/^after:(\S+)$/i))) {
      out.after = m[1];
      out.chips.push({ kind: "after", label: tok, raw: tok });
      continue;
    }
    if ((m = tok.match(/^filetype:(\S+)$/i))) {
      out.filetype = m[1];
      out.chips.push({ kind: "filetype", label: tok, raw: tok });
      continue;
    }
    keep.push(tok);
  }
  out.clean = keep.join(" ").trim();
  out.timeRange = timeRangeFor(out.after, out.before);
  return out;
}

export function buildSearxParams(ops, pageno) {
  let q = ops.clean;
  for (const s of ops.sites) q += ` site:${s}`;
  for (const s of ops.notSites) q += ` -site:${s}`;
  if (ops.filetype) q += ` filetype:${ops.filetype}`;
  const params = { q: q.trim(), pageno: String(pageno) };
  if (ops.language) params.language = ops.language;
  if (ops.timeRange) params.time_range = ops.timeRange;
  return params;
}
