// Reader-mode preview: fetch a result page server-side, strip it to text.
// SSRF-defended: DNS resolution checked, private ranges blocked, size and
// timeout caps, redirect loop bounded.

import { lookup } from "node:dns/promises";
import { config } from "./config.js";
import { htmlToText } from "./util.js";

const MAX_BYTES = 3 * 1024 * 1024;
const MAX_TEXT = 20000;
const MAX_REDIRECTS = 2;

export function isPrivateIp(ip) {
  if (ip.includes(":")) {
    const v = ip.toLowerCase();
    return v === "::1" || v.startsWith("fc") || v.startsWith("fd") || v.startsWith("fe80") || v === "::";
  }
  const parts = ip.split(".").map(Number);
  if (parts.length !== 4) return true;
  const [a, b] = parts;
  if (a === 10 || a === 127 || a === 0) return true;
  if (a === 192 && b === 168) return true;
  if (a === 172 && b >= 16 && b <= 31) return true;
  if (a === 169 && b === 254) return true;
  if (a === 100 && b >= 64 && b <= 127) return true;
  return false;
}

export async function fetchOnce(urlStr, redirectsLeft) {
  const u = new URL(urlStr);
  if (!/^https?:$/.test(u.protocol)) throw new Error("only http(s) URLs");
  let addrs;
  try {
    addrs = await lookup(u.hostname, { all: true });
  } catch {
    throw new Error("DNS lookup failed");
  }
  if (!addrs.length || addrs.some((a) => isPrivateIp(a.address))) throw new Error("blocked address");

  const res = await fetch(u, {
    headers: { "User-Agent": config.userAgent, Accept: "text/html,application/xhtml+xml" },
    redirect: "manual",
    signal: AbortSignal.timeout(7000),
  });
  if ([301, 302, 303, 307, 308].includes(res.status)) {
    if (redirectsLeft <= 0) throw new Error("too many redirects");
    const loc = res.headers.get("location");
    if (!loc) throw new Error("redirect without location");
    res.body?.cancel();
    return fetchOnce(new URL(loc, u).toString(), redirectsLeft - 1);
  }
  if (!res.ok) throw new Error(`upstream ${res.status}`);
  return res;
}

export async function fetchPreview(urlStr) {
  const res = await fetchOnce(urlStr, MAX_REDIRECTS);
  const ct = res.headers.get("content-type") || "";
  if (!ct.includes("html") && !ct.includes("xml") && !ct.startsWith("text/")) {
    return { title: "", text: `[non-HTML content: ${ct.split(";")[0]}]`, truncated: false };
  }
  const buf = await res.arrayBuffer();
  const truncated = buf.byteLength > MAX_BYTES;
  const html = new TextDecoder("utf-8", { fatal: false }).decode(buf.slice(0, MAX_BYTES));
  const titleMatch = html.match(/<title[^>]*>([\s\S]*?)<\/title>/i);
  const title = titleMatch ? htmlToText(titleMatch[1]).slice(0, 200) : "";
  // Drop headers/nav/footer noise crudely before stripping tags.
  const body = html
    .replace(/<(script|style|noscript|svg|iframe|form|nav|footer|header)[\s\S]*?<\/\1>/gi, " ")
    .replace(/<(nav|footer|header)[^>]*>[\s\S]*?<\/\1>/gi, " ");
  const text = htmlToText(body);
  return { title, text: text.slice(0, MAX_TEXT), truncated };
}
