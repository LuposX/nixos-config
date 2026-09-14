{ config, ... }: let
  domain = config.var.domain;
  port = 8080;
in {
  # Miniflux 2 (https://github.com/miniflux/v2) — minimalistic feed reader.
  # Miniflux 2 is PostgreSQL-only; the nixpkgs module provisions the local
  # database and role (services.postgresql.enable is set by the module).
  services.miniflux = {
    enable = true;

    # ADMIN_USERNAME / ADMIN_PASSWORD for the initial account. Only read while
    # the database has no users yet (CREATE_ADMIN=1, RUN_MIGRATIONS=1).
    adminCredentialsFile = config.sops.secrets.miniflux-admin-credentials.path;

    config = {
      # Only reachable from nginx on the same host.
      LISTEN_ADDR = "127.0.0.1:${toString port}";
      BASE_URL = "https://miniflux.${domain}";

      # TLS is terminated by nginx; mark session cookies Secure.
      HTTPS = 1;
    };
  };
}