# websearch

Kagi-style frontend for the local SearXNG instance. Zero runtime
dependencies, one Node process, plain ESM.

## What it adds on top of SearXNG

- **Lenses** — JSON files in `lenses/` with `block` / `boost` / `downrank`
  host lists. Switchable top-right or via the palette.
- **Personalized results** — every result you open nudges that host's
  factor up over time (capped); `b` / `B` / `d` on a result set block /
  boost / downrank explicitly. Persisted in `$WEBSEARCH_STATE_DIR/personal.json`.
- **Bangs** — `!gh rust` redirects to GitHub itself. Full DDG bang list,
  cached weekly in `$WEBSEARCH_STATE_DIR/bangs.json`. Internal vertical
  bangs `!i !v !n !m !w` switch the images/videos/news/maps/web tab.
- **Tabs** — web, images, videos, news, maps, backed by SearXNG
  categories. Image thumbnails are proxied through `/api/img` so
  third-party CDNs never see your IP.
- **Site info modal** — `s` on a result shows its host, lens and personal
  factors; `l`/`h` step boost/downrank levels, `b` blocks, `r` resets.
- **Operators** — `site:` `-site:` `lang:` `after:` `before:` `filetype:`
  with live chips above the input.
- **Keyboard control** — `j/k`/arrows move, `o`/`Enter` open, `c` copy, `e`
  explain rank, `Space` reader preview, `q` quick answer, `s` site info
  modal, `S` snap, `u` undo personal action, `b`/`B`/`d` personal rules,
  `w/i/v/m/n` tabs + `]`/`[` cycle, `1-9` jump, `!` bang prefill, `/` focus,
  `Ctrl-K` palette, `?` cheatsheet.
- **Snaps** — pinned queries/URLs above the results (`s` saves the
  current query). Persisted in `$WEBSEARCH_STATE_DIR/snaps.json`.
- **Quick Answer** — streams from any OpenAI-compatible endpoint
  (OpenRouter, ollama `/v1`, LM Studio `/v1`). Disabled unless
  `WEBSEARCH_LLM_BASE_URL` and `WEBSEARCH_LLM_MODEL` are set.
- **Small web** — through SearXNG's Marginalia engine plus the bundled
  `smallweb` lens.

## Config (env)

| Variable | Default | Purpose |
|---|---|---|
| `PORT` | `3040` | HTTP port |
| `HOST` | `127.0.0.1` | Bind address — keep local |
| `WEBSEARCH_SEARXNG_BASE_URL` | `http://127.0.0.1:8080` | SearXNG URL |
| `WEBSEARCH_STATE_DIR` | `./data` | personal.json, snaps, bang cache |
| `WEBSEARCH_LENS` | `default` | Lens active at startup |
| `WEBSEARCH_LLM_BASE_URL` | — | OpenAI-compatible endpoint for Quick Answer |
| `WEBSEARCH_LLM_API_KEY` | — | Bearer token (OpenRouter etc.) |
| `WEBSEARCH_LLM_MODEL` | — | Model id |

## NixOS

`nixos/websearch.nix` exposes `services.websearch` (`enable`, `port`,
`host`, `searxngUrl`, `defaultLens`, `environmentFile` for the LLM
secrets). State lives in `/var/lib/websearch`.

## Ranking

SearXNG's merged ordering is the base (reciprocal rank), multiplied by
the lens factor and the personal factor. Press `e` on any result for the
breakdown — no black box.
