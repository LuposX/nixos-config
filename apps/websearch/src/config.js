import path from "node:path";

const stateDir = process.env.WEBSEARCH_STATE_DIR || path.join(process.cwd(), "data");

export const config = {
  port: Number(process.env.PORT) || 3040,
  host: process.env.HOST || "127.0.0.1",
  searxngBaseUrl: (process.env.WEBSEARCH_SEARXNG_BASE_URL || "http://127.0.0.1:8080").replace(/\/$/, ""),
  stateDir,
  lensDir: process.env.WEBSEARCH_LENS_DIR || path.join(process.cwd(), "lenses"),
  defaultLens: process.env.WEBSEARCH_LENS || "default",
  userAgent: "websearch/1.0 (self-hosted)",
  llm: {
    // Any OpenAI-compatible endpoint: OpenRouter, ollama (/v1), LM Studio (/v1)
    baseUrl: process.env.WEBSEARCH_LLM_BASE_URL || null,
    apiKey: process.env.WEBSEARCH_LLM_API_KEY || null,
    model: process.env.WEBSEARCH_LLM_MODEL || null,
  },
};
