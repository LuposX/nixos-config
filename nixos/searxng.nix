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
        formats = ["html" "json"];
      };

      # Engine mix. Default SearXNG leans on resold Google/Bing results
      # (duckduckgo = Bing, startpage = Google), where "agreement" between
      # engines is often the same index counted twice. These enable the
      # independent crawls instead — Mojeek and Brave are the same indexes
      # Kagi licenses directly.
      engines = [
        # Independent indexes (no API key needed).
        # `inactive = false` is required for engines upstream has parked
        # (inactive: true in the default settings — mojeek: CAPTCHA wall,
        # marginalia: mid-API-migration); `disabled = false` alone won't
        # resurrect them.
        { name = "mojeek"; disabled = false; inactive = false; }
        { name = "mwmbl"; disabled = false; }
        { name = "wiby"; disabled = false; }

        # Disabled on purpose (2026-11):
        #  - yep: api.yep.com now sits behind a Cloudflare bot-wall — the
        #    engine gets challenge pages, unfixable via settings. Re-check
        #    on searxng updates.
        #  - searchmysite: HTML xpath scraper, searchmysite.net denies bots
        #    (and it was disabled upstream anyway).
        #  - startpage: parked upstream (proof-of-work wall), and it's a
        #    Google reseller, which is what we want less of.

        # Small web — Marginalia. For now this uses the shared public key
        # (https://about.marginalia-search.com/article/api/): it works but is
        # rate-limited across all users, so expect occasional per-request
        # errors, and custom filters are not allowed on it. When you get a
        # personal key, add to the sops searxng-env secret:
        #   MARGINALIA_API_KEY=<key>
        # and change "public" below to "$MARGINALIA_API_KEY".
        { name = "marginalia"; disabled = false; inactive = false; api_key = "public"; }

        # The Google scrape workaround is fragile and low-quality
        # (switched off upstream, revived via their custom-search widget).
        # Keep it for coverage but rank it below the independents.
        { name = "google cse"; weight = 0.5; }
      ];

      general = {
        instance_name = "SearXNG";
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

  environment.systemPackages = [pkgs.searxng];
}
