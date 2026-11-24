// Quick Answer: stream a grounded answer from any OpenAI-compatible
// chat-completions endpoint (OpenRouter, ollama /v1, LM Studio /v1).
// Disabled unless WEBSEARCH_LLM_BASE_URL + WEBSEARCH_LLM_MODEL are set.

import { config } from "./config.js";

export function llmConfigured() {
  return Boolean(config.llm.baseUrl && config.llm.model);
}

const SYSTEM = [
  "You answer search queries using ONLY the numbered search results given.",
  "Be concise: at most 150 words. Cite sources inline as [1], [2].",
  "If the results do not contain the answer, say so plainly. No preamble.",
].join(" ");

export async function* streamAnswer(query, results) {
  const ctx = results
    .slice(0, 8)
    .map((r, i) => `[${i + 1}] ${r.title}\n${r.url}\n${(r.content || r.snippet || "").slice(0, 400)}`)
    .join("\n\n");

  const headers = { "Content-Type": "application/json" };
  if (config.llm.apiKey) headers.Authorization = `Bearer ${config.llm.apiKey}`;

  const res = await fetch(`${config.llm.baseUrl.replace(/\/$/, "")}/chat/completions`, {
    method: "POST",
    headers,
    body: JSON.stringify({
      model: config.llm.model,
      stream: true,
      max_tokens: 400,
      messages: [
        { role: "system", content: SYSTEM },
        { role: "user", content: `Search query: ${query}\n\nSearch results:\n${ctx}` },
      ],
    }),
    signal: AbortSignal.timeout(90_000),
  });
  if (!res.ok) {
    const text = await res.text().catch(() => "");
    throw new Error(`LLM ${res.status}: ${text.slice(0, 200)}`);
  }

  const decoder = new TextDecoder();
  let buf = "";
  for await (const chunk of res.body) {
    buf += decoder.decode(chunk, { stream: true });
    let idx;
    while ((idx = buf.indexOf("\n")) >= 0) {
      const line = buf.slice(0, idx).trim();
      buf = buf.slice(idx + 1);
      if (!line.startsWith("data:")) continue;
      const payload = line.slice(5).trim();
      if (payload === "[DONE]") return;
      try {
        const delta = JSON.parse(payload)?.choices?.[0]?.delta?.content;
        if (delta) yield delta;
      } catch {
        /* keep-alive or partial line */
      }
    }
  }
}
