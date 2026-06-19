# See: https://hermes-agent.nousresearch.com/docs/getting-started/nix-setup
{ inputs, config, pkgs, ... }: let
  username = config.var.username;
in {
  services.hermes-agent = {
    enable = true;
    extraDependencyGroups = [ "messaging" "hindsight" ];

    settings = {
      model = {
        default = "deepseek-v4-flash";
        provider = "deepseek";
        base_url = "https://api.deepseek.com/v1";
      };

      dashboard.show_token_analytics = true;

      memory.provider = "hindsight";

      compression = {
        threshold = 0.40;
        protect_last_n = 15;
      };

      # Hindsight self-hosted via local_external mode (Docker container)
      hindsight = {
        mode = "local_external";
        api_url = "http://127.0.0.1:8888";
      };

      # Explicitly set SearXNG as the search backend
      # (auto-detection from SEARXNG_URL also works, but explicit is safer)
      web = {
        search_backend = "searxng";
        extract_backend = "tavily";
      };

      # Tredict MCP server for AI-powered training analysis
      # Create an access token in Tredict → Settings → Access Tokens
      # Add TREDICT_MCP_TOKEN=<token> to your sops hermes-env secret
      mcp_servers.tredict = {
        url = "https://www.tredict.com/api/mcp/v2";
        headers.Authorization = "Bearer $" + "{TREDICT_MCP_TOKEN}";
      };

      # Disable unused toolsets to keep the tool list leaner
      agent.disabled_toolsets = [
        "browser"
        "image_gen"
        "tts"
        "computer_use"
      ];

      # Skills unused for current academic work (neural net fault detection
      # research).  Disabled here → excluded from the system prompt, saving
      # ~1,300–1,500 tokens per turn.  Re-enable by removing from this list.
      # See `hermes skills list` for all available skills.
      skills.disabled = [
        # Creative — media generation, design, music, animation
        "ascii-art" "ascii-video"
        "baoyu-article-illustrator" "baoyu-comic" "baoyu-infographic"
        "claude-design" "comfyui" "design-md" "ideation"
        "manim-video" "p5js" "pixel-art" "popular-web-designs"
        "pretext" "songwriting-and-ai-music" "touchdesigner-mcp"

        # Gaming
        "minecraft-modpack-server" "pokemon-player"

        # Media — GIFs, music, streaming
        "gif-search" "heartmula" "songsee" "spotify" "youtube-content"

        # MLOps — local inference/model serving (not used; API-based only)
        "audiocraft-audio-generation" "dspy"
        "evaluating-llms-harness" "huggingface-hub"
        "llama-cpp" "obliteratus" "segment-anything-model"
        "serving-llms-vllm" "weights-and-biases"

        # Productivity — project management, maps, PDF editing
        "airtable" "linear" "notion" "maps"
        "nano-pdf" "teams-meeting-pipeline"
        "obsidian"

        # Other AI agent CLIs (not using them here)
        "claude-code" "codex" "opencode"

        # Kanban multi-agent workflow (not using)
        "kanban-orchestrator" "kanban-worker" "kanban-codex-lane"

        # Social media, messaging
        "xurl" "yuanbao" "dogfood"

        # DevOps — webhooks
        "webhook-subscriptions"

        # Red-teaming
        "godmode"

        # Research — prediction markets, RSS, wiki (unused)
        "blogwatcher" "llm-wiki" "polymarket"

        # Smart-home
        "openhue"

        # Email, MCP
        "native-mcp"

        # Container supervision (not using OCI container mode)
        "hermes-s6-container-supervision"

        # Debugging TUI commands (not using the TUI)
        "debugging-hermes-tui-commands"
      ];
    };

    environmentFiles = [
      config.sops.secrets."hermes-env".path
      # HINDSIGHT_MODE must be in .env so both systemd service and CLI pick it up.
      # The plugin's _load_config() falls back to env vars; without it, mode
      # defaults to "cloud" and is_available() returns False.
      "${pkgs.writeText "hermes-hindsight-env" "HINDSIGHT_MODE=local_external\n"}"
    ];

    addToSystemPackages = true;
  };

  # Add your user to the hermes group so you can access the shared
  # HERMES_HOME (/var/lib/hermes/.hermes/) without sudo.
  users.users.${username}.extraGroups = [ "hermes"];

  # Tell Hermes to use the local SearXNG instance for web search.
  # Hermes auto-detects SEARXNG_URL and uses SearXNG as the search backend.
  systemd.services.hermes-agent.environment = {
    SEARXNG_URL = "http://127.0.0.1:8080";
    # Tell the hindsight plugin to connect to our self-hosted Docker container.
    # Mode=local_external → default API URL is http://localhost:8888 (correct port).
    HINDSIGHT_MODE = "local_external";
  };
}