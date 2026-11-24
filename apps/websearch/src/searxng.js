import { config } from "./config.js";

export async function searchSearxng(params, timeoutMs = 9000) {
  const qs = new URLSearchParams({ format: "json", ...params });
  const res = await fetch(`${config.searxngBaseUrl}/search?${qs}`, {
    headers: { "User-Agent": config.userAgent, Accept: "application/json" },
    signal: AbortSignal.timeout(timeoutMs),
  });
  if (!res.ok) {
    throw new Error(`SearXNG returned ${res.status}`);
  }
  return res.json();
}
