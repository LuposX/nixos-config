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

  # Pi's own secret: OpenRouter API key. Each host carries the key in its
  # own secrets file so the module stays host-independent.
  openrouterKey = "openrouter-api-key";
  openrouterSopsFile =
    {
      pneuma = ../hosts/laptop/secrets/secrets.yaml;
      logos = ../hosts/desktop/secrets/secrets.yaml;
    }
    .${config.var.hostname} or ../hosts/laptop/secrets/secrets.yaml;
  # Wrap pi so the OpenRouter key is injected at launch, independent of
  # the calling shell. Shell-init exports only reach shells started after
  # a rebuild; wrappers (and launchers) always get the current secret.
  piWrapped = pkgs.writeShellScriptBin "pi" ''
    if [ -z "''${OPENROUTER_API_KEY:-}" ] && [ -r /run/secrets/${openrouterKey} ]; then
      export OPENROUTER_API_KEY="$(cat /run/secrets/${openrouterKey})"
    fi
    exec ${pkgs.pi}/bin/pi "$@"
  '';
in {
  nixpkgs.overlays = [
    inputs.pi.overlays.default
  ];

  environment.systemPackages = [
    piWrapped
    pkgs.jq
    # Runtime for MCP stdio servers spawned via `npx -y ...` (mcp-searxng)
    pkgs.nodejs
  ];

  sops.secrets.${openrouterKey} = {
    format = "yaml";
    sopsFile = openrouterSopsFile;
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
    home.file.".pi/agent/skills/humanizer/SKILL.md".source =
      "${humanizerSrc}/SKILL.md";

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
  };
}
