// Image proxy for the images tab: keeps third-party CDNs from seeing the
// browser's IP (same reason Kagi proxies images). SSRF-guarded.

import { fetchOnce } from "./preview.js";

const MAX_BYTES = 5 * 1024 * 1024;

export async function fetchImage(urlStr) {
  const res = await fetchOnce(urlStr, 2);
  const type = (res.headers.get("content-type") || "").split(";")[0].trim();
  if (!type.startsWith("image/")) throw new Error(`not an image: ${type}`);
  const buf = await res.arrayBuffer();
  if (buf.byteLength > MAX_BYTES) throw new Error("image too large");
  return { buf: Buffer.from(buf), type };
}
