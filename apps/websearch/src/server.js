import http from "node:http";
import { readFile } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { config } from "./config.js";
import { json, sendErr, readJson, hostOf } from "./util.js";
import { searchSearxng } from "./searxng.js";
import { parseQuery, buildSearxParams } from "./operators.js";
import { listLenses, loadLens } from "./lens.js";
import * as personal from "./personal.js";
import { rank } from "./rank.js";
import { resolveBang, bangCount } from "./bangs.js";
import * as snaps from "./snaps.js";
import { fetchPreview } from "./preview.js";
import { fetchImage } from "./img.js";
import { streamAnswer, llmConfigured } from "./answer.js";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const webDir = path.join(__dirname, "web");

const MIME = {
  ".html": "text/html; charset=utf-8",
  ".js": "text/javascript; charset=utf-8",
  ".css": "text/css; charset=utf-8",
  ".json": "application/json; charset=utf-8",
  ".svg": "image/svg+xml",
  ".png": "image/png",
  ".ico": "image/x-icon",
};

function sendFile(res, file, status = 200) {
  readFile(file)
    .then((data) => {
      res.writeHead(status, {
        "Content-Type": MIME[path.extname(file)] || "application/octet-stream",
        "Content-Length": data.length,
        "Cache-Control": "no-store",
      });
      res.end(data);
    })
    .catch(() => sendErr(res, 404, "not found"));
}

async function apiSearch(req, res, url) {
  const q = url.searchParams.get("q") || "";
  const lensName = url.searchParams.get("lens") || config.defaultLens;
  const pageno = Math.max(1, Number(url.searchParams.get("p")) || 1);
  const t0 = Date.now();

  const ops = parseQuery(q);
  const params = buildSearxParams(ops, pageno);
  // Vertical: from an internal bang (!i !v !n !m) or the active tab.
  const catParam = url.searchParams.get("cat");
  const vertical = ops.vertical || (catParam && catParam !== "general" ? catParam : null);
  if (vertical) params.categories = vertical;
  let data;
  try {
    data = await searchSearxng(params);
  } catch (e) {
    sendErr(res, 502, `SearXNG unreachable: ${e.message}`);
    return;
  }

  const lens = await loadLens(lensName);
  const p = await personal.load();
  const ranked = rank(data.results || [], lens, p);

  json(res, 200, {
    query: q,
    page: pageno,
    lens: lensName,
    results: ranked.results,
    blocked: ranked.blocked,
    answers: data.answers || [],
    infoboxes: data.infoboxes || [],
    suggestions: data.suggestions || [],
    meta: {
      ops,
      enginesQueried: [...new Set((data.results || []).flatMap((r) => r.engines || []))],
      tookMs: Date.now() - t0,
    },
  });
}

async function apiAnswer(req, res, url) {
  const q = url.searchParams.get("q") || "";
  const lensName = url.searchParams.get("lens") || config.defaultLens;
  if (!q.trim()) return sendErr(res, 400, "missing q");
  if (!llmConfigured()) return sendErr(res, 503, "no LLM configured (set WEBSEARCH_LLM_BASE_URL and WEBSEARCH_LLM_MODEL)");

  let results;
  try {
    const ops = parseQuery(q);
    const data = await searchSearxng(buildSearxParams(ops, 1));
    const lens = await loadLens(lensName);
    const p = await personal.load();
    results = rank(data.results || [], lens, p).results;
  } catch (e) {
    return sendErr(res, 502, `search failed: ${e.message}`);
  }

  res.writeHead(200, {
    "Content-Type": "text/event-stream",
    "Cache-Control": "no-store",
    Connection: "keep-alive",
  });
  try {
    for await (const delta of streamAnswer(q, results)) {
      res.write(`data: ${JSON.stringify({ delta })}\n\n`);
    }
    res.write("data: [DONE]\n\n");
  } catch (e) {
    res.write(`data: ${JSON.stringify({ error: e.message })}\n\n`);
  }
  res.end();
}

const server = http.createServer(async (req, res) => {
  const url = new URL(req.url, `http://${req.headers.host || "localhost"}`);
  const pathname = url.pathname;

  // Security headers on everything.
  res.setHeader("X-Content-Type-Options", "nosniff");
  res.setHeader("Referrer-Policy", "no-referrer");
  res.setHeader(
    "Content-Security-Policy",
    "default-src 'none'; script-src 'self'; style-src 'self'; img-src 'self'; connect-src 'self'; base-uri 'none'; form-action 'self'",
  );

  try {
    if (req.method === "GET") {
      switch (true) {
        case pathname === "/" || pathname === "/search":
          return sendFile(res, path.join(webDir, "index.html"));
        case pathname.startsWith("/static/"):
          return sendFile(res, path.join(webDir, pathname.slice("/static/".length).replace(/\.\./g, "")));
        case pathname === "/healthz":
          return json(res, 200, { ok: true });
        case pathname === "/api/search":
          return apiSearch(req, res, url);
        case pathname === "/api/lenses":
          return json(res, 200, { lenses: await listLenses(), default: config.defaultLens });
        case pathname === "/api/personal":
          return json(res, 200, await personal.load());
        case pathname === "/api/snaps":
          return json(res, 200, await snaps.load());
        case pathname === "/api/bangs.js": {
          const count = await bangCount();
          return json(res, 200, { count });
        }
        case pathname === "/api/bangs/resolve": {
          const r = await resolveBang(url.searchParams.get("q") || "");
          return json(res, 200, r || { url: null });
        }
        case pathname === "/api/preview": {
          try {
            return json(res, 200, await fetchPreview(url.searchParams.get("url") || ""));
          } catch (e) {
            return sendErr(res, 502, e.message);
          }
        }
        case pathname === "/api/answer":
          return apiAnswer(req, res, url);
        case pathname === "/api/img": {
          try {
            const { buf, type } = await fetchImage(url.searchParams.get("url") || "");
            res.writeHead(200, {
              "Content-Type": type,
              "Content-Length": buf.length,
              "Cache-Control": "private, max-age=3600",
            });
            res.end(buf);
          } catch (e) {
            sendErr(res, 502, e.message);
          }
          return;
        }
        case pathname === "/api/sources":
          return json(res, 200, {
            searxng: config.searxngBaseUrl,
            llm: llmConfigured() ? { baseUrl: config.llm.baseUrl, model: config.llm.model } : null,
            stateDir: config.stateDir,
          });
      }
    }

    if (req.method === "POST") {
      switch (true) {
        case pathname === "/api/personal": {
          const body = await readJson(req);
          const host = hostOf(body.url) || body.host || "";
          const result = await personal.apply(body.action, host);
          return json(res, 200, { ...result, state: await personal.load() });
        }
        case pathname === "/api/snaps": {
          const body = await readJson(req);
          return json(res, 200, await snaps.add(body));
        }
        case pathname === "/api/snaps/delete": {
          const body = await readJson(req);
          return json(res, 200, await snaps.remove(String(body.id || "")));
        }
      }
    }

    sendErr(res, 404, "not found");
  } catch (e) {
    if (!res.headersSent) sendErr(res, 500, e.message);
    else res.end();
  }
});

server.listen(config.port, config.host, () => {
  console.log(`websearch listening on http://${config.host}:${config.port}`);
  console.log(`  searxng: ${config.searxngBaseUrl}`);
  console.log(`  quick answer: ${llmConfigured() ? config.llm.model : "disabled"}`);
  console.log(`  state: ${config.stateDir}`);
});
