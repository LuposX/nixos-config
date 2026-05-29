# See: https://hermes-agent.nousresearch.com/docs/getting-started/nix-setup
{ inputs, config, pkgs, ... }: let
  username = config.var.username;
in {
  services.hermes-agent = {
    enable = true;
    extraDependencyGroups = [ "messaging" "hindsight" ];

    settings = {
      model.default = "deepseek-v4-flash";

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

      # Disable unused toolsets to keep the tool list leaner
      agent.disabled_toolsets = [
        "browser"
        "image_gen"
        "tts"
        "computer_use"
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
