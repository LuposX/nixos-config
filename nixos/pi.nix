# Pi coding agent (https://github.com/earendil-works/pi)
{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: let
  username = config.var.username;

  # Declarative Pi settings seed. Applied only where the key is still missing,
  # so Pi-managed values (/settings, Ctrl+S saved defaults) are never clobbered.
  piSettings = pkgs.writeText "pi-settings.json" (builtins.toJSON {
    defaultProvider = "openrouter";
    defaultModel = "z-ai/glm-5.3-flash";
    defaultThinkingLevel = "high";
    tuiMode = "fullscreen";
    # Keep Ctrl+P / /model cycling usable: flash default, full glm for hard
    # tasks
    enabledModels = [
      "z-ai/glm-5.3-flash"
      "z-ai/glm-5.3"
      "moonshotai/kimi-k3.1-pro"
      "openai/gpt-6.1-sol"
    ];
    enableInstallTelemetry = false;
    # Run Pi's shell commands inside the project's direnv environment.
    # Pi prepends this as a script line (prefix + "\n" + command), so the
    # prefix must be a standalone statement. "direnv exec ." can't work here
    # (it requires a COMMAND argument); "direnv export bash" prints the env
    # diff as shell code and is a silent no-op without an .envrc.
    shellCommandPrefix = "eval \"$(direnv export bash)\"";
    # pi-web-access: web_search / fetch_content / source_check, PDF
    # extraction, GitHub-URL cloning, YouTube + local video understanding.
    # Its search chain prefers the self-hosted SearXNG (see web-search.json).
    packages = ["npm:pi-web-access"];
  });

  # pi-web-access provider config: route web search through the local
  # SearXNG instance first. The SSRF guard blocks private ranges, so the
  # loopback range must be allowed explicitly for 127.0.0.1:8080.
  piWebSearch = pkgs.writeText "pi-web-search.json" (builtins.toJSON {
    searxngBaseUrl = "http://127.0.0.1:8080";
    ssrf.allowRanges = ["127.0.0.0/8"];
  });

  # User-level MCP servers. The standalone searxng MCP server is disabled:
  # pi-web-access covers the same search via its own SearXNG provider and
  # adds fetch/extraction/PDF/video tools on top. Seeded only if missing —
  # Pi saves /mcp exposure changes into this file.
  piMcp = pkgs.writeText "pi-mcp.json" (builtins.toJSON {
    mcpServers.searxng = {
      enabled = false;
      command = "npx";
      args = ["-y" "mcp-searxng"];
      env = {
        SEARXNG_URL = "http://127.0.0.1:8080";
      };
      description = "Web search via the local self-hosted SearXNG instance";
    };
  });

  # Global Pi instructions: how the user writes. Applied in every project.
  piAgents = pkgs.writeText "pi-AGENTS.md" ''
    # My voice

    When you rewrite or edit prose for me, keep it in my voice — how I
    actually write — not in assistant style.

    How I write:
    - Plain, direct sentences. State the point; no run-ups, no closers.
    - Passive voice and no "we" in academic/formal writing.
    - Citations support the specific claim they are attached to, never a
      bare reference hanging off a paragraph.
    - No one-sentence paragraphs; merge short subsections into prose
      instead of leaving them isolated.
    - Concise: match answer length to question weight. No filler.
    - Keep my terminology consistent; never rename established terms or
      "fix" deliberate quirks.

    Rules for rewrites:
    - Use the humanizer skill to strip AI writing patterns, then shape the
      result to the voice above.
    - If I give you a writing sample, the sample's rhythm, word choice and
      punctuation override these rules.
    - If you are unsure how I would phrase something, ask for a sample
      instead of guessing.
  '';

  # Humanizer skill (https://github.com/blader/humanizer): strips AI
  # writing patterns; answers to /skill:humanizer. Vendored read-only —
  # Pi only reads skills, so a symlink into the store is fine.
  humanizerSrc = pkgs.fetchFromGitHub {
    owner = "blader";
    repo = "humanizer";
    rev = "225a6f39ac85f76ee48dbad772ea4abe4ed6c9d8";
    hash = "sha256-n8cbTzhlGf8VnWpPukq7XD2mucIrqyE1XMpAAc5oA8A=";
  };

  # KIT KI-Toolbox (https://www.scc.kit.edu/en/services/ki-toolbox.php):
  # OpenAI-compatible LiteLLM endpoint, personal API key from the web UI
  # (Settings -> Accounts -> API Key). Externally routed models (GPT,
  # Gemini, Claude) bill against a per-user monthly budget (default $5);
  # the local models (kit.*) are free. Usage dashboard:
  # https://my.litellm.scc.kit.edu
  kitKey = "kit-api-key";

  # Fully declarative models.json for the university agent directory.
  # Reinstalled on every activation (no user edits expected here); model
  # metadata is conservative — verify context windows against the
  # KI-Toolbox /docs endpoint if needed. Context windows for azure.gpt*
  # stay at 272k to remain inside the cheaper pricing tier.
  piUniModels = pkgs.writeText "pi-uni-models.json" (builtins.toJSON {
    "$schema" = "https://pi.dev/schemas/models.schema.json";
    providers.kit = {
      name = "KIT KI-Toolbox";
      baseUrl = "https://ki-toolbox.scc.kit.edu/api";
      api = "openai-completions";
      # Read at request time from the sops-rendered secret (owned by the
      # user), so the key never lands in an environment variable.
      apiKey = "!cat /run/secrets/${kitKey}";
      models = [
        {
          type = "chat";
          id = "kit.mistral-small-4-119b-a8b";
          name = "Mistral Small 4 (local)";
          reasoning = false;
          input = ["text"];
          cost = { input = 0; output = 0; cacheRead = 0; cacheWrite = 0; };
          contextWindow = 128000;
          maxTokens = 32768;
        }
        {
          type = "chat";
          id = "kit.deepseek-v4-flash";
          name = "DeepSeek V4 Flash (local)";
          reasoning = false;
          input = ["text"];
          cost = { input = 0; output = 0; cacheRead = 0; cacheWrite = 0; };
          contextWindow = 128000;
          maxTokens = 32768;
        }
        {
          type = "chat";
          id = "kit.glm-5.3-flash";
          name = "GLM-5.3 Flash (local)";
          reasoning = false;
          input = ["text"];
          cost = { input = 0; output = 0; cacheRead = 0; cacheWrite = 0; };
          contextWindow = 128000;
          maxTokens = 32768;
        }
        {
          type = "chat";
          id = "alias.simple-gpt";
          name = "GPT-6 Luna (simple)";
          reasoning = true;
          input = ["text" "image"];
          cost = { input = 0.12; output = 0.6; cacheRead = 0.012; cacheWrite = 0.15; };
          contextWindow = 272000;
          maxTokens = 32768;
        }
        {
          type = "chat";
          id = "alias.medium-gpt";
          name = "GPT-5.6 Terra (medium)";
          reasoning = true;
          input = ["text" "image"];
          cost = { input = 2.2; output = 13.2; cacheRead = 0.22; cacheWrite = 2.75; };
          contextWindow = 272000;
          maxTokens = 32768;
        }
        {
          type = "chat";
          id = "alias.complex-gpt";
          name = "GPT-6.1 Sol (complex)";
          reasoning = true;
          input = ["text" "image"];
          cost = { input = 2.4; output = 12; cacheRead = 0.24; cacheWrite = 3; };
          contextWindow = 272000;
          maxTokens = 32768;
        }
        {
          type = "chat";
          id = "alias.simple-claude";
          name = "Claude Haiku 5.5 (simple)";
          reasoning = true;
          input = ["text" "image"];
          cost = { input = 0.11; output = 0.55; cacheRead = 0.011; cacheWrite = 0.1375; };
          contextWindow = 200000;
          maxTokens = 32768;
        }
        {
          type = "chat";
          id = "alias.medium-claude";
          name = "Claude Sonnet 5.5 (medium)";
          reasoning = true;
          input = ["text" "image"];
          cost = { input = 2.2; output = 11; cacheRead = 0.22; cacheWrite = 2.75; };
          contextWindow = 200000;
          maxTokens = 32768;
        }
      ];
    };
  });

  # University settings seed: default to a local (free, data stays at
  # KIT) model; externals are opt-in via /model or the enabledModels list.
  piUniSettings = pkgs.writeText "pi-uni-settings.json" (builtins.toJSON {
    defaultProvider = "kit";
    defaultModel = "kit/kit.deepseek-v4-flash";
    defaultThinkingLevel = "high";
    tuiMode = "fullscreen";
    enabledModels = [
      "kit/kit.deepseek-v4-flash"
      "kit/kit.mistral-small-4-119b-a8b"
      "kit/kit.glm-5.3-flash"
      "kit/alias.simple-claude"
      "kit/alias.simple-gpt"
      "kit/alias.medium-claude"
      "kit/alias.complex-gpt"
    ];
    enableInstallTelemetry = false;
    shellCommandPrefix = "eval \"$(direnv export bash)\"";
    packages = ["npm:pi-web-access"];
  });

  # Shared secrets file (encrypted to all personal machines + recovery,
  # see .sops.yaml at the repo root). Both pi keys follow the user across
  # hosts, so they live there rather than in a per-host yaml.
  commonSopsFile = ../secrets/common.json;
  openrouterKey = "openrouter-api-key";
  # Wrap pi so the OpenRouter key is injected at launch, independent of
  # the calling shell. Shell-init exports only reach shells started after
  # a rebuild; wrappers (and launchers) always get the current secret.
  piWrapped = pkgs.writeShellScriptBin "pi" ''
    if [ -z "''${OPENROUTER_API_KEY:-}" ] && [ -r /run/secrets/${openrouterKey} ]; then
      export OPENROUTER_API_KEY="$(cat /run/secrets/${openrouterKey})"
    fi
    exec ${pkgs.pi}/bin/pi "$@"
  '';

  # pi-uni: second agent identity that talks exclusively to the KIT
  # KI-Toolbox. Runs pi with a separate config directory (~/.pi/agent-uni,
  # seeded below), so it has its own settings, sessions, and model
  # catalog. Calls the unwrapped pi binary directly — the OpenRouter key
  # from the wrapper above is never exported, and provider keys leaking
  # in from the shell are dropped, so only the KIT key (read at request
  # time from /run/secrets) is reachable.
  piuWrapped = pkgs.writeShellScriptBin "piu" ''
    exec env -u OPENROUTER_API_KEY -u ANTHROPIC_API_KEY -u OPENAI_API_KEY \
      PI_CODING_AGENT_DIR="$HOME/.pi/agent-uni" \
      ${pkgs.pi}/bin/pi "$@"
  '';
in {
  nixpkgs.overlays = [
    inputs.pi.overlays.default
  ];

  environment.systemPackages = [
    piWrapped
    piuWrapped
    pkgs.jq
    # Runtime for MCP stdio servers spawned via `npx -y ...` (mcp-searxng)
    pkgs.nodejs
  ];

  sops.secrets.${openrouterKey} = {
    format = "json";
    sopsFile = commonSopsFile;
    owner = username;
  };

  # Owned by the user so pi's `!cat` at request time can read it.
  sops.secrets.${kitKey} = {
    format = "json";
    sopsFile = commonSopsFile;
    owner = username;
  };

  environment.interactiveShellInit = ''
    # Pi (coding agent): OpenRouter credentials from sops
    if [ -r /run/secrets/${openrouterKey} ]; then
      export OPENROUTER_API_KEY="$(cat /run/secrets/${openrouterKey})"
    fi
  '';

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      # Pi (coding agent): OpenRouter credentials from sops
      if test -r /run/secrets/${openrouterKey}
        set -x OPENROUTER_API_KEY (cat /run/secrets/${openrouterKey})
      end
    '';
  };

  home-manager.users.${username} = {lib, ...}: {
    # Read-only, Pi only reads these: global voice rules + humanizer skill
    home.file.".pi/agent/AGENTS.md".source = piAgents;
    home.file.".pi/agent/skills/humanizer/SKILL.md".source = "${humanizerSrc}/SKILL.md";
    # Share voice rules and skills with the university agent directory too.
    home.file.".pi/agent-uni/AGENTS.md".source = piAgents;
    home.file.".pi/agent-uni/skills/humanizer/SKILL.md".source = "${humanizerSrc}/SKILL.md";

    home.activation.piSettings = lib.hm.dag.entryAfter ["writeBoundary"] ''
      mkdir -p "$HOME/.pi/agent"
      if [ ! -f "$HOME/.pi/agent/settings.json" ]; then
        cp ${piSettings} "$HOME/.pi/agent/settings.json"
      else
        # Add declarative defaults only for keys the user hasn't set yet
        tmp="$(mktemp)"
        jq --slurpfile seed ${piSettings} \
          'reduce ($seed[0] | keys_unsorted[]) as $k (.; if has($k) then . else . + {($k): $seed[0][$k]} end)' \
          "$HOME/.pi/agent/settings.json" > "$tmp" \
          && mv "$tmp" "$HOME/.pi/agent/settings.json"
      fi
      if [ ! -f "$HOME/.pi/agent/mcp.json" ]; then
        cp ${piMcp} "$HOME/.pi/agent/mcp.json"
      else
        # The standalone searxng MCP server is superseded by pi-web-access
        tmp="$(mktemp)"
        jq '.mcpServers.searxng.enabled = false' \
          "$HOME/.pi/agent/mcp.json" > "$tmp" \
          && mv "$tmp" "$HOME/.pi/agent/mcp.json"
      fi
      if [ ! -f "$HOME/.pi/agent/web-search.json" ]; then
        cp ${piWebSearch} "$HOME/.pi/agent/web-search.json"
      fi
    '';

    home.activation.piUniAgent = lib.hm.dag.entryAfter ["writeBoundary"] ''
      mkdir -p "$HOME/.pi/agent-uni"
      # models.json is fully declarative: reinstall on every activation.
      install -m 644 ${piUniModels} "$HOME/.pi/agent-uni/models.json"
      if [ ! -f "$HOME/.pi/agent-uni/settings.json" ]; then
        cp ${piUniSettings} "$HOME/.pi/agent-uni/settings.json"
      else
        # Same merge discipline as the main directory: only fill in keys
        # the user hasn't set through Pi's own UI.
        tmp="$(mktemp)"
        jq --slurpfile seed ${piUniSettings} \
          'reduce ($seed[0] | keys_unsorted[]) as $k (.; if has($k) then . else . + {($k): $seed[0][$k]} end)' \
          "$HOME/.pi/agent-uni/settings.json" > "$tmp" \
          && mv "$tmp" "$HOME/.pi/agent-uni/settings.json"
      fi
    '';
  };
}
