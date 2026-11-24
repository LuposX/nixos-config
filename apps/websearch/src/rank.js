import { isBlocked as lensBlocked, factorFor as lensFactorFor } from "./lens.js";
import * as personal from "./personal.js";

// Base score: reciprocal-rank over SearXNG's own merged ordering, then
// multiply by the lens factor and the personal factor. Fully explainable:
// every result carries its parts.
export function rank(results, lens, pstate) {
  const out = [];
  let blocked = 0;
  (results || []).forEach((r, i) => {
    const host = hostOfSafe(r.url);
    if (lensBlocked(lens, host) || personal.isBlocked(pstate, host)) {
      blocked += 1;
      return;
    }
    const lensFactor = lensFactorFor(lens, host);
    const personalFactor = personal.factorFor(pstate, host);
    const base = 100 / (60 + i);
    const score = base * lensFactor * personalFactor;
    out.push({
      ...r,
      host,
      base: Number(base.toFixed(4)),
      lensFactor: Number(lensFactor.toFixed(3)),
      personalFactor: Number(personalFactor.toFixed(3)),
      score: Number(score.toFixed(4)),
    });
  });
  out.sort((a, b) => b.score - a.score);
  out.forEach((r, i) => (r.rank = i + 1));
  return { results: out, blocked };
}

function hostOfSafe(url) {
  try {
    return new URL(url).hostname.toLowerCase().replace(/^www\./, "");
  } catch {
    return null;
  }
}
