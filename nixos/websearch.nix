{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.services.websearch;
  appSrc = ../apps/websearch;
in {
  # websearch — Kagi-style frontend for the local SearXNG instance.
  #
  # Features: lenses, DDG bangs, operators + keyboard nav, snaps,
  # reader preview, personalized ranking (clicks boost hosts over time),
  # and an optional LLM-backed Quick Answer.
  #
  # After `nixos-rebuild switch`:
  #   - Web UI: http://localhost:3040
  #   - Requires services.searx with formats = ["html" "json"]
  #
  # Quick Answer needs an OpenAI-compatible endpoint. Add to a sops env file:
  #   WEBSEARCH_LLM_BASE_URL=https://openrouter.ai/api/v1
  #   WEBSEARCH_LLM_API_KEY=sk-or-...
  #   WEBSEARCH_LLM_MODEL=openai/gpt-...   (or a local ollama /v1 endpoint)
  # and point services.websearch.environmentFile at it.

  options.services.websearch = {
    enable = lib.mkEnableOption "websearch, a Kagi-style frontend for SearXNG";

    port = lib.mkOption {
      type = lib.types.port;
      default = 3040;
    };

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Bind address. Keep local-only unless you add auth.";
    };

    searxngUrl = lib.mkOption {
      type = lib.types.str;
      default = "http://127.0.0.1:8080";
      description = "Base URL of the SearXNG instance (JSON format must be enabled).";
    };

    defaultLens = lib.mkOption {
      type = lib.types.str;
      default = "default";
    };

    environmentFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Optional sops env file with WEBSEARCH_LLM_* variables for Quick Answer.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.websearch = {
      description = "websearch — Kagi-style frontend for SearXNG";
      wantedBy = ["multi-user.target"];
      after = ["network.target"];

      environment = {
        PORT = toString cfg.port;
        HOST = cfg.host;
        WEBSEARCH_SEARXNG_BASE_URL = cfg.searxngUrl;
        WEBSEARCH_LENS = cfg.defaultLens;
        WEBSEARCH_STATE_DIR = "/var/lib/websearch";
      };

      serviceConfig = {
        ExecStart = "${pkgs.nodejs}/bin/node ${appSrc}/src/server.js";
        WorkingDirectory = "${appSrc}";
        StateDirectory = "websearch";
        DynamicUser = true;
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        RestrictAddressFamilies = ["AF_INET" "AF_INET6" "AF_UNIX"];
        Restart = "on-failure";
        RestartSec = 3;
      };
    };
  };
}
