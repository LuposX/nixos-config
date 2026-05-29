{
  config,
  pkgs,
  lib,
  ...
}: {
  # SearXNG — self-hosted, privacy-respecting metasearch engine
  #
  # Resource usage: ~100-200 MB RAM, minimal CPU (only when searching).
  # Runs fine on a laptop in the background.
  #
  # After `nixos-rebuild switch`:
  #   - Web UI: http://localhost:8080
  #   - Hermes auto-detects SEARXNG_URL and uses it for web_search
  #
  # The secret key is managed via sops-nix. To set it up:
  #   1. Generate a key:  openssl rand -base64 64
  #   2. Add to sops:     sops hosts/desktop/secrets/secrets.yaml
  #      Content: searxng-env: |\n    SEARX_SECRET_KEY=<your_key>
  #
  # To enable Redis for rate limiting (+ ~50MB RAM):
  #   services.searx.redisCreateLocally = true;

  services.searx = {
    enable = true;

    # Built-in HTTP server — lightweight, no Nginx/uWSGI needed for local use
    configureUwsgi = false;

    # Manage the secret key via sops-nix
    environmentFile = config.sops.secrets."searxng-env".path;

    settings = {
      # Merge with SearXNG defaults
      use_default_settings = true;

      server = {
        port = 8080;
        bind_address = "127.0.0.1"; # Local only — no firewall needed
        secret_key = "$SEARX_SECRET_KEY";
      };

      search = {
        safe_search = 0;
        autocomplete = "";
        language = "en-US";
        formats = [ "html" "json" ];
      };

      general = {
        instance_name = "SearXNG (Hermes)";
        debug = false;
        privacypolicy_url = false;
        contact_url = false;
        enable_metrics = false;
      };

      ui = {
        static_use_hash = true;
        default_theme = "simple";
        default_locale = "en";
      };
    };
  };

  environment.systemPackages = [ pkgs.searxng ];
}
