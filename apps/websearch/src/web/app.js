// websearch frontend — zero dependencies, no framework.

// ---------- tiny helpers ----------

const $ = (sel) => document.querySelector(sel);

function el(tag, attrs = {}, ...children) {
  const node = document.createElement(tag);
  for (const [k, v] of Object.entries(attrs)) {
    if (v == null) continue;
    if (k === "className") node.className = v;
    else if (k.startsWith("on")) node.addEventListener(k.slice(2), v);
    else if (k === "html") node.innerHTML = v; // only used with trusted/escaped content built below
    else node.setAttribute(k, v);
  }
  for (const child of children.flat()) {
    if (child == null) continue;
    node.append(child);
  }
  return node;
}


let toastTimer;
function toast(msg) {
  const t = $("#toast");
  t.textContent = msg;
  t.classList.add("show");
  clearTimeout(toastTimer);
  toastTimer = setTimeout(() => t.classList.remove("show"), 1800);
}

async function api(path, opts) {
  const res = await fetch(path, opts);
  const data = await res.json().catch(() => ({}));
  if (!res.ok) throw new Error(data.error || res.statusText);
  return data;
}

function relativeTime(ms) {
  const s = Math.round(ms / 1000);
  if (s < 90) return "just now";
  if (s < 3600) return `${Math.round(s / 60)}m ago`;
  if (s < 86400) return `${Math.round(s / 3600)}h ago`;
  return `${Math.round(s / 86400)}d ago`;
}

// ---------- local trail (click memory) ----------

const TRAIL_KEY = "websearch:trail";
const RECENT_KEY = "websearch:recent";

function lsGet(key, fallback) {
  try { return JSON.parse(localStorage.getItem(key)) || fallback; } catch { return fallback; }
}
function lsSet(key, value) {
  try { localStorage.setItem(key, JSON.stringify(value)); } catch { /* quota */ }
}

function trailEntry(url) {
  return lsGet(TRAIL_KEY, []).find((e) => e.url === url);
}
function recordTrail(r) {
  const trail = lsGet(TRAIL_KEY, []).filter((e) => e.url !== r.url);
  trail.unshift({ url: r.url, title: r.title, query: state.query, ts: Date.now() });
  lsSet(TRAIL_KEY, trail.slice(0, 300));
}
function recordRecent(q) {
  const rec = lsGet(RECENT_KEY, []).filter((x) => x !== q);
  rec.unshift(q);
  lsSet(RECENT_KEY, rec.slice(0, 30));
}

// ---------- state ----------

const state = {
  query: "",
  cat: "general",
  lens: null,
  lenses: [],
  page: 1,
  results: [],
  meta: null,
  suggestions: [],
  selected: -1,
  data: null, // full result object of the selected row
  snaps: [],
  personal: null,
  lastPersonalAction: null,
  answerText: "",
};

// ---------- operator chips (client mirror of server parser) ----------


const CHIP_RE = [
  [/^!([a-z0-9_-]+)$/i, "bang"],
  [/^site:(.+)$/i, "site"],
  [/^-site:(.+)$/i, "notsite"],
  [/^lang:([a-zA-Z-]+)$/, "lang"],
  [/^before:(\S+)$/i, "before"],
  [/^after:(\S+)$/i, "after"],
  [/^filetype:(\S+)$/i, "filetype"],
];

// Internal vertical bangs switch the tab instead of redirecting.
const VERTICALS = { i: "images", v: "videos", n: "news", m: "maps", w: "general", k: "general" };
const TAB_ORDER = ["general", "images", "videos", "news", "maps"];
const TAB_LABEL = { general: "web", images: "images", videos: "videos", news: "news", maps: "maps" };

function parseChips(q) {
  return q.split(/\s+/).filter(Boolean).map((tok) => {
    for (const [re, kind] of CHIP_RE) {
      if (re.test(tok)) return { kind, label: tok };
    }
    return null;
  }).filter(Boolean);
}

function renderChips() {
  const box = $("#chips");
  box.replaceChildren();
  for (const chip of parseChips($("#q").value)) {
    box.append(
      el("span", {
        className: `chip ${chip.kind}`,
        title: "click to remove",
        onclick: () => {
          $("#q").value = $("#q").value.split(/\s+/).filter((t) => t !== chip.label).join(" ");
          renderChips();
          $("#q").focus();
        },
      }, chip.label),
    );
  }
}

// ---------- rendering ----------

function renderHome() {
  main().replaceChildren(
    el("div", { className: "home" },
      el("h1", {}, "web", el("span", {}, "search")),
      el("div", { className: "hint" }, "press ", el("kbd", {}, "?"), " for the cheatsheet, ", el("kbd", {}, "Ctrl-K"), " for the palette"),
    ),
  );
  $("#snaps").replaceChildren(...renderSnaps());
  $("#statusbar").replaceChildren();
  $("#answer").replaceChildren();
}

function main() { return $("main"); }

function renderSnaps() {
  return state.snaps.map((s) =>
    el("span", { className: "snap", onclick: () => (s.query ? go(s.query) : (window.location.href = s.url)) },
      s.name,
      el("span", {
        className: "rm",
        title: "remove snap",
        onclick: async (ev) => {
          ev.stopPropagation();
          await api("/api/snaps/delete", { method: "POST", body: JSON.stringify({ id: s.id }) });
          state.snaps = await api("/api/snaps");
          $("#snaps").replaceChildren(...renderSnaps());
          toast("snap removed");
        },
      }, "×"),
    ),
  );
}

function renderResults(data) {
  state.results = data.results;
  state.meta = data.meta;
  state.suggestions = data.suggestions || [];
  state.selected = data.results.length ? 0 : -1;

  const snapRow = $("#snaps");
  snapRow.replaceChildren(...renderSnaps());

  const list = el("div", {});
  if (!data.results.length) {
    list.append(el("p", { className: "hint" }, `no results${data.blocked ? ` (${data.blocked} filtered by lens/personal rules)` : ""}`));
  }
  if (state.cat === "images") {
    list.className = "img-grid";
    for (const r of data.results) list.append(renderImageCard(r));
  } else {
    for (const r of data.results) list.append(renderResult(r));
  }
  main().replaceChildren(list);

  const bar = $("#statusbar");
  bar.replaceChildren(
    el("span", {}, `${data.results.length} results · ${data.meta.tookMs} ms · engines: ${data.meta.enginesQueried.join(", ") || "—"}`),
    data.blocked ? el("span", {}, `${data.blocked} filtered`) : null,
    el("span", { className: "next", onclick: nextPage }, "next page →"),
  );
  select(0);
}

function renderResult(r) {
  const trail = trailEntry(r.url);
  const tags = [];
  if (r.lensFactor !== 1) tags.push(el("span", { className: "tag lens", title: "lens factor" }, `lens ×${r.lensFactor}`));
  if (r.personalFactor !== 1) tags.push(el("span", { className: "tag lens", title: personalSource(r.host) }, `you ×${r.personalFactor}`));
  if (trail) tags.push(el("span", { className: "tag visited", title: `last visited ${new Date(trail.ts).toLocaleString()}` }, `visited ${relativeTime(Date.now() - trail.ts)}`));

  const node = el("div", { className: "result", "data-url": r.url },
    el("div", { className: "r-top" },
      el("span", { className: "r-host" }, r.host || ""),
      el("span", {}, (r.engines || []).join(", ")),
      r.publishedDate ? el("span", {}, new Date(r.publishedDate).toLocaleDateString()) : null,
      tags,
    ),
    el("div", { className: "r-title" },
      el("a", { href: r.url, target: "_blank", rel: "noopener noreferrer nofollow", onclick: (ev) => { ev.preventDefault(); openResult(r); } }, r.title || r.url),
    ),
    r.content ? el("div", { className: "r-snippet" }, r.content) : null,
    el("div", { className: "explain" },
      el("div", {}, el("b", {}, "final score: "), `${r.score} = base ${r.base} × lens ${r.lensFactor} × personal ${r.personalFactor}`),
      el("div", {}, el("b", {}, "personal: "), personalSource(r.host)),
      el("div", {}, el("b", {}, "found by: "), (r.engines || []).join(", ")),
    ),
  );
  return node;
}

function renderImageCard(r) {
  return el("div", { className: "result img-card" },
    el("img", {
      src: `/api/img?url=${encodeURIComponent(r.img_src || r.thumbnail_src || "")}`,
      loading: "lazy",
      alt: r.title || "",
      onclick: () => openResult(r),
    }),
    el("div", { className: "r-title" },
      el("a", { href: r.url, target: "_blank", rel: "noopener noreferrer nofollow", onclick: (ev) => { ev.preventDefault(); openResult(r); } }, r.title || r.url),
    ),
  );
}

function personalSource(host) {
  const p = state.personal || { boost: {}, downrank: {}, block: [] };
  if (p.block?.includes(host)) return "blocked";
  const parts = [];
  const b = p.boost?.[host];
  if (b) parts.push(`boost ×${b.factor} (${b.n} clicks)`);
  const d = p.downrank?.[host];
  if (d) parts.push(`downrank ×${d.factor}`);
  return parts.join(", ") || "neutral";
}

// ---------- selection ----------

function resultNodes() {
  return [...document.querySelectorAll(".result")];
}

function select(i) {
  const nodes = resultNodes();
  if (!nodes.length) return;
  state.selected = Math.max(0, Math.min(nodes.length - 1, i));
  nodes.forEach((n, idx) => n.classList.toggle("selected", idx === state.selected));
  nodes[state.selected].scrollIntoView({ block: "nearest" });
  state.data = state.results[state.selected];
}

function openResult(r) {
  recordTrail(r);
  api("/api/personal", { method: "POST", body: JSON.stringify({ action: "click", host: r.host }) })
    .then((d) => (state.personal = d.state))
    .catch(() => {});
  window.open(r.url, "_blank", "noopener");
}

// ---------- search ----------

async function go(q, { page = 1, push = true } = {}) {
  q = q.trim();
  if (!q) return;
  state.query = q;
  state.page = page;
  recordRecent(q);

  // Bangs: internal vertical bangs (!i !v !n !m !w) switch the tab;
  // anything else is a DDG-style redirect.
  const lead = q.match(/^\s*!([a-z0-9_-]+)/i);
  if (lead && VERTICALS[lead[1].toLowerCase()]) {
    state.cat = VERTICALS[lead[1].toLowerCase()];
    renderTabs();
  } else if (page === 1 && /^\s*!/.test(q)) {
    try {
      const r = await api(`/api/bangs/resolve?q=${encodeURIComponent(q)}`);
      if (r && r.url) {
        window.location.href = r.url;
        return;
      }
      toast(`no bang matches — searching instead`);
    } catch { /* fall through to normal search */ }
  }

  $("#q").value = q;
  renderChips();
  if (push) history.pushState({}, "", `/search?q=${encodeURIComponent(q)}&lens=${encodeURIComponent(state.lens)}${page > 1 ? `&p=${page}` : ""}`);

  main().replaceChildren(el("p", { className: "hint" }, "searching…"));
  try {
    const data = await api(`/api/search?q=${encodeURIComponent(q)}&lens=${encodeURIComponent(state.lens)}&p=${page}&cat=${state.cat}`);
    renderResults(data);
  } catch (e) {
    main().replaceChildren(el("p", { className: "hint" }, `search failed: ${e.message}`));
  }
}

function nextPage() {
  go(state.query, { page: state.page + 1, push: false });
}

// ---------- personal actions ----------

async function personalAction(action, host) {
  if (!host) return;
  const d = await api("/api/personal", { method: "POST", body: JSON.stringify({ action, host }) });
  state.personal = d.state;
  state.lastPersonalAction = { action, host };
  const msgs = { block: `blocked ${host}`, unblock: `unblocked ${host}`, boost: `boosted ${host}`, downrank: `downranked ${host}`, reset: `reset ${host}` };
  toast(msgs[action] || `applied ${action}`);
  go(state.query, { page: state.page, push: false });
  if (!$("#siteinfo").classList.contains("hidden")) setTimeout(renderSiteInfo, 50);
}

// ---------- site info modal (personalized results UI) ----------

let siteInfoHost = null;

function openSiteInfo() {
  if (!state.data) { toast("no result selected"); return; }
  siteInfoHost = state.data.host;
  closeOverlays("#siteinfo");
  $("#siteinfo").classList.remove("hidden");
  renderSiteInfo();
}

function renderSiteInfo() {
  const host = siteInfoHost;
  if (!host) return;
  const r = state.results.find((x) => x.host === host) || {};
  const p = state.personal || { boost: {}, downrank: {}, block: [] };
  const blocked = (p.block || []).includes(host);
  const b = p.boost?.[host];
  const d = p.downrank?.[host];

  $("#siteinfo").querySelector(".panel").replaceChildren(
    el("h3", {}, "site info"),
    el("table", {},
      el("tr", {}, el("td", {}, "host"), el("td", {}, host || "—")),
      el("tr", {}, el("td", {}, "title"), el("td", {}, r.title || "—")),
      el("tr", {}, el("td", {}, "found by"), el("td", {}, (r.engines || []).join(", ") || "—")),
      el("tr", {}, el("td", {}, "lens factor"), el("td", {}, r.lensFactor != null ? `×${r.lensFactor}` : "—")),
      el("tr", {}, el("td", {}, "personal"), el("td", {},
        blocked ? "blocked"
        : [b && `boost ×${b.factor} (${b.n} clicks)`, d && `downrank ×${d.factor}`].filter(Boolean).join(", ") || "neutral",
      )),
      el("tr", {}, el("td", {}, "actions"), el("td", {},
        "l boost · h downrank · b block · r reset · esc close",
      )),
    ),
    el("div", { style: "margin-top:10px;display:flex;gap:8px;flex-wrap:wrap" },
      el("button", { className: "btn", onclick: () => siteInfoKey("l") }, "boost (l)"),
      el("button", { className: "btn", onclick: () => siteInfoKey("h") }, "downrank (h)"),
      el("button", { className: "btn", onclick: () => siteInfoKey("b") }, blocked ? "unblock (b)" : "block (b)"),
      el("button", { className: "btn", onclick: () => siteInfoKey("r") }, "reset (r)"),
    ),
  );
}

function siteInfoKey(key) {
  const host = siteInfoHost;
  if (!host) return;
  const p = state.personal || { block: [] };
  if (key === "l") personalAction("boost", host);
  else if (key === "h") personalAction("downrank", host);
  else if (key === "b") personalAction(p.block?.includes(host) ? "unblock" : "block", host);
  else if (key === "r") personalAction("reset", host);
}

// ---------- quick answer ----------

async function quickAnswer() {
  if (!state.query) return;
  const box = $("#answer");
  box.replaceChildren(
    el("div", { className: "ans-head" }, "quick answer"),
    el("span", {}, "thinking…"),
  );
  state.answerText = "";
  try {
    const res = await fetch(`/api/answer?q=${encodeURIComponent(state.query)}&lens=${encodeURIComponent(state.lens)}`);
    if (!res.ok) {
      const d = await res.json().catch(() => ({}));
      box.replaceChildren();
      toast(d.error || "quick answer unavailable");
      return;
    }
    const reader = res.body.getReader();
    const dec = new TextDecoder();
    let buf = "";
    for (;;) {
      const { done, value } = await reader.read();
      if (done) break;
      buf += dec.decode(value, { stream: true });
      let idx;
      while ((idx = buf.indexOf("\n\n")) >= 0) {
        const line = buf.slice(0, idx).trim();
        buf = buf.slice(idx + 2);
        if (!line.startsWith("data:")) continue;
        const payload = line.slice(5).trim();
        if (payload === "[DONE]") continue;
        try {
          const d = JSON.parse(payload);
          if (d.error) { toast(d.error); continue; }
          if (d.delta) {
            state.answerText += d.delta;
            box.replaceChildren(
              el("div", { className: "ans-head" }, "quick answer"),
              el("span", {}, state.answerText + "▌"),
            );
          }
        } catch { /* partial */ }
      }
    }
    box.replaceChildren(el("div", { className: "ans-head" }, "quick answer"), el("span", {}, state.answerText));
  } catch (e) {
    box.replaceChildren();
    toast(`answer failed: ${e.message}`);
  }
}

// ---------- reader preview ----------

let previewOpen = false;

async function togglePreview(url) {
  const pane = $("#preview");
  if (previewOpen) {
    pane.classList.remove("open");
    previewOpen = false;
    return;
  }
  if (!url) return;
  previewOpen = true;
  pane.classList.add("open");
  pane.replaceChildren(el("span", { className: "close", onclick: () => togglePreview() }, "esc"), el("h3", {}, "preview"), el("p", { className: "hint" }, "fetching…"));
  try {
    const d = await api(`/api/preview?url=${encodeURIComponent(url)}`);
    pane.replaceChildren(
      el("span", { className: "close", onclick: () => togglePreview() }, "esc"),
      el("h3", {}, d.title || url),
      el("pre", {}, d.text),
    );
  } catch (e) {
    pane.replaceChildren(el("span", { className: "close", onclick: () => togglePreview() }, "esc"), el("p", { className: "hint" }, `preview failed: ${e.message}`));
  }
}

// ---------- tabs (verticals) ----------

function renderTabs() {
  const box = $("#tabs");
  if (!box) return;
  box.replaceChildren(
    ...TAB_ORDER.map((cat) =>
      el("span", {
        className: `tab${state.cat === cat ? " active" : ""}`,
        onclick: () => setTab(cat),
      }, TAB_LABEL[cat]),
    ),
  );
}

function setTab(cat) {
  state.cat = cat;
  renderTabs();
  if (state.query) go(state.query, { page: 1, push: false });
}

function cycleTab(dir) {
  const i = TAB_ORDER.indexOf(state.cat);
  setTab(TAB_ORDER[(i + dir + TAB_ORDER.length) % TAB_ORDER.length]);
}

// ---------- cheatsheet ----------

const CHEATSHEET = [
  ["j / k / ↓ / ↑", "move highlight"],
  ["o / Enter", "open selected result"],
  ["c", "copy URL"],
  ["e", "explain rank (score breakdown)"],
  ["Space", "reader preview of selected result"],
  ["q / a", "quick answer (needs LLM configured)"],
  ["s", "site info modal — boost/ban status"],
  ["S", "save current query as a snap"],
  ["b", "block selected host"],
  ["B", "boost selected host"],
  ["d", "downrank selected host"],
  ["u", "undo last block/boost/downrank"],
  ["w i v n m", "switch tab (web/images/videos/news/maps)"],
  ["] / [", "cycle tabs"],
  ["1-9", "jump to result n"],
  ["/", "focus search box"],
  ["!", "focus search box, start a bang"],
  ["Ctrl-K", "command palette"],
  ["Esc", "close overlay / reset highlight"],
  ["", ""],
  ["!bang", "all DuckDuckGo bangs (e.g. !gh, !w, !yt)"],
  ["!i !v !n !m", "search images / videos / news / maps"],
  ["site:example.com", "only results from host"],
  ["-site:reddit.com", "exclude host"],
  ["lang:de", "results language"],
  ["after:3d before:today", "date range (also YYYY-MM-DD)"],
  ["filetype:pdf", "file type"],
  ["inurl: intitle:\"\" - + OR *", "passed through to the engines"],
  ["", ""],
  ["lenses", "block/boost/downrank hosts, switchable top-right"],
  ["personal rules", "clicks you make boost hosts over time — s modal or b/B/d set them explicitly"],
];

function toggleCheatsheet() {
  const ov = $("#cheatsheet");
  if (!ov.classList.contains("hidden")) { ov.classList.add("hidden"); return; }
  closeOverlays(ov);
  ov.classList.remove("hidden");
}

// ---------- command palette ----------

let paletteItems = [];
let paletteIndex = 0;

function paletteCommands(filter) {
  const cmds = [];
  for (const q of lsGet(RECENT_KEY, []).slice(0, 8)) {
    cmds.push({ label: q, hint: "recent", run: () => go(q) });
  }
  for (const l of state.lenses) {
    cmds.push({ label: `lens: ${l}`, hint: "switch lens", run: () => switchLens(l) });
  }
  for (const s of state.snaps) {
    cmds.push({ label: `snap: ${s.name}`, hint: "open", run: () => (s.query ? go(s.query) : (window.location.href = s.url)) });
  }
  cmds.push({ label: "save snap (current query)", hint: "snaps", run: saveSnap });
  cmds.push({ label: "clear local trail", hint: "privacy", run: () => { lsSet(TRAIL_KEY, []); toast("trail cleared"); } });
  if (state.query) cmds.push({ label: `search: ${state.query}`, hint: "current", run: () => go(state.query) });
  const f = (filter || "").toLowerCase();
  return f ? cmds.filter((c) => c.label.toLowerCase().includes(f)) : cmds;
}

function renderPalette() {
  const list = $("#palette-list");
  paletteItems = paletteCommands($("#palette-input").value);
  paletteIndex = Math.max(0, Math.min(paletteItems.length - 1, paletteIndex));
  list.replaceChildren(...paletteItems.map((c, i) =>
    el("div", {
      className: `palette-item${i === paletteIndex ? " selected" : ""}`,
      onclick: () => { closeOverlays(); c.run(); },
    },
      el("span", {}, c.label),
      el("span", { className: "hint" }, c.hint),
    ),
  ));
}

function openPalette() {
  closeOverlays($("#palette"));
  $("#palette").classList.remove("hidden");
  const input = $("#palette-input");
  input.value = "";
  paletteIndex = 0;
  renderPalette();
  input.focus();
}

function closeOverlays(except) {
  for (const id of ["#cheatsheet", "#palette", "#siteinfo"]) {
    if (id !== except) $(id).classList.add("hidden");
  }
  if ($("#preview").classList.contains("open") && except !== "#preview") togglePreview();
}


// ---------- snaps / lens ----------

async function saveSnap() {
  if (!state.query) { toast("nothing to snap — run a search first"); return; }
  state.snaps = await api("/api/snaps", { method: "POST", body: JSON.stringify({ name: state.query, query: state.query }) });
  $("#snaps").replaceChildren(...renderSnaps());
  toast(`snapped “${state.query}”`);
}

async function switchLens(name) {
  state.lens = name;
  $("#lens-select").value = name;
  if (state.query) go(state.query, { page: 1, push: false });
  toast(`lens: ${name}`);
}

// ---------- keyboard ----------

document.addEventListener("keydown", (ev) => {
  const paletteOpen = !$("#palette").classList.contains("hidden");
  const cheatsheetOpen = !$("#cheatsheet").classList.contains("hidden");

  if (ev.key === "Escape") {
    if (previewOpen) { togglePreview(); return; }
    if (cheatsheetOpen || paletteOpen) { closeOverlays(); return; }
    const siteEl = $("#siteinfo");
    if (siteEl && !siteEl.classList.contains("hidden")) { siteEl.classList.add("hidden"); return; }
  }

  if (paletteOpen) {
    if (ev.key === "ArrowDown") { paletteIndex = Math.min(paletteItems.length - 1, paletteIndex + 1); renderPalette(); ev.preventDefault(); return; }
    if (ev.key === "ArrowUp") { paletteIndex = Math.max(0, paletteIndex - 1); renderPalette(); ev.preventDefault(); return; }
    if (ev.key === "Enter") {
      const item = paletteItems[paletteIndex];
      if (item) { closeOverlays(); item.run(); }
      ev.preventDefault();
      return;
    }
    return; // typing in palette input
  }
  if (cheatsheetOpen) return;

  const inInput = ["INPUT", "TEXTAREA", "SELECT"].includes(document.activeElement?.tagName);
  if ((ev.ctrlKey || ev.metaKey) && ev.key.toLowerCase() === "k") {
    ev.preventDefault();
    openPalette();
    return;
  }
  if (inInput) {
    if (ev.key === "Enter" && document.activeElement === $("#q")) {
      ev.preventDefault();
      go($("#q").value);
    }
    if (ev.key === "Escape") document.activeElement.blur();
    return;
  }

  const siteInfoOpen = !$("#siteinfo").classList.contains("hidden");
  if (siteInfoOpen) {
    if (["b", "B", "d", "h", "l", "r"].includes(ev.key)) siteInfoKey(ev.key);
    return;
  }

  switch (ev.key) {
    case "j": case "ArrowDown": select(state.selected + 1); break;
    case "k": case "ArrowUp": select(state.selected - 1); break;
    case "o": case "Enter": if (state.data) openResult(state.data); break;
    case "c": if (state.data) { navigator.clipboard.writeText(state.data.url); toast("URL copied"); } break;
    case "e": {
      const nodes = resultNodes();
      if (nodes[state.selected]) nodes[state.selected].querySelector(".explain").classList.toggle("open");
      break;
    }
    case " ": ev.preventDefault(); if (state.data) togglePreview(state.data.url); break;
    case "q": case "a": quickAnswer(); break;
    case "!":
      ev.preventDefault();
      $("#q").focus();
      $("#q").value = $("#q").value ? `${$("#q").value} !` : "!";
      renderChips();
      break;
    case "s": openSiteInfo(); break;
    case "S": saveSnap(); break;
    case "b": if (state.data) personalAction("block", state.data.host); break;
    case "B": if (state.data) personalAction("boost", state.data.host); break;
    case "d": if (state.data) personalAction("downrank", state.data.host); break;
    case "w": case "i": case "v": case "n": case "m":
      if (VERTICALS[ev.key]) setTab(VERTICALS[ev.key]);
      break;
    case "]": cycleTab(1); break;
    case "[": cycleTab(-1); break;
    case "u":
      if (state.lastPersonalAction) {
        const { action, host } = state.lastPersonalAction;
        const undoMap = { block: "unblock", boost: "unboost", downrank: "undownrank" };
        if (undoMap[action]) personalAction(undoMap[action], host);
        state.lastPersonalAction = null;
      } else toast("nothing to undo");
      break;
    case "/": ev.preventDefault(); $("#q").focus(); break;
    case "?": toggleCheatsheet(); break;
    case "Escape":
      if (state.results.length) select(0);
      break;
    default:
      if (/^[1-9]$/.test(ev.key)) select(Number(ev.key) - 1);
  }
});

// ---------- boot ----------

async function init() {
  const [lenses, personal, snaps, sources] = await Promise.all([
    api("/api/lenses"),
    api("/api/personal").catch(() => ({})),
    api("/api/snaps").catch(() => []),
    api("/api/sources").catch(() => ({})),
  ]);
  state.lenses = lenses.lenses || ["default"];
  state.lens = lenses.default || "default";
  state.personal = personal && personal.boost !== undefined ? personal : null;
  state.snaps = Array.isArray(snaps) ? snaps : [];

  // Build static chrome.
  document.body.append(
    el("header", {},
      el("span", { className: "logo", onclick: () => { history.pushState({}, "", "/"); renderHome(); } }, "ws▸"),
      el("div", { id: "searchbox" },
        el("input", { id: "q", placeholder: "search — try !gh rust · site: · lang: · ? for help", autofocus: true, oninput: renderChips }),
        el("select", {
          id: "lens-select",
          title: "active lens",
          onchange: (ev) => switchLens(ev.target.value),
        }, state.lenses.map((l) => el("option", { value: l }, l))),
      ),
    ),
    el("div", { id: "chips" }),
    el("div", { id: "tabs" }),
    el("main", {},
      el("div", { id: "snaps" }),
      el("div", { id: "answer" }),
    ),
    el("div", { id: "statusbar" }),
    el("aside", { id: "preview" }),
    el("div", { id: "toast" }),
    // cheatsheet overlay
    el("div", { id: "cheatsheet", className: "overlay hidden", onclick: (ev) => { if (ev.target.id === "cheatsheet") closeOverlays(); } },
      el("div", { className: "panel" },
        el("h3", {}, "cheatsheet"),
        el("table", {}, CHEATSHEET.map(([k, v]) => el("tr", {}, el("td", {}, k), el("td", {}, v)))),
      ),
    ),
    // palette overlay
    el("div", { id: "palette", className: "overlay hidden", onclick: (ev) => { if (ev.target.id === "palette") closeOverlays(); } },
      el("div", { className: "panel" },
        el("input", { id: "palette-input", placeholder: "type a command or query…", oninput: () => { paletteIndex = 0; renderPalette(); } }),
        el("div", { id: "palette-list" }),
      ),
    ),
    // site info overlay
    el("div", { id: "siteinfo", className: "overlay hidden", onclick: (ev) => { if (ev.target.id === "siteinfo") closeOverlays(); } },
      el("div", { className: "panel" }),
    ),
  );

  renderTabs();

  const params = new URLSearchParams(location.search);
  const q = params.get("q");
  const lensParam = params.get("lens");
  if (lensParam && state.lenses.includes(lensParam)) state.lens = lensParam;
  $("#lens-select").value = state.lens;

  if (sources && sources.llm) toast(`quick answer: ${sources.llm.model}`);

  if (q) go(q, { page: Number(params.get("p")) || 1, push: false });
  else renderHome();

  window.addEventListener("popstate", () => {
    const p = new URLSearchParams(location.search);
    const pq = p.get("q");
    if (pq) go(pq, { page: Number(p.get("p")) || 1, push: false });
    else renderHome();
  });
}

init();
