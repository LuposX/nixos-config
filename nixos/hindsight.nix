{
  config,
  pkgs,
  lib,
  ...
}: let
  apiPort = 8888; # Hindsight API server
  ctrlPort = 9999; # Hindsight Control Plane (UI) — optional
in {
  # Ensure Docker is enabled (should already be in configuration.nix)
  virtualisation.docker.enable = true;

  # Run Hindsight as a Docker container
  virtualisation.oci-containers = {
    backend = "docker";

    containers.hindsight = {
      image = "ghcr.io/vectorize-io/hindsight:latest";
      autoStart = true;

      ports = [
        "127.0.0.1:${toString apiPort}:8888" # API — localhost only
        "127.0.0.1:${toString ctrlPort}:9999" # Web UI — localhost only
      ];

      # Load env vars from sops-managed secret
      environmentFiles = [
        config.sops.secrets."hindsight-env".path
      ];

      # Persist embedded PostgreSQL database across restarts
      volumes = [
        "/var/lib/hindsight/data:/home/hindsight/.pg0"
      ];

      # No extraOptions needed — uses --rm (systemd manages lifecycle)
      # and --pull missing (pulls if not cached)
    };
  };

  # Ensure data directory exists with proper permissions
  # The container user (hindsight, UID 1000) needs write access
  systemd.tmpfiles.rules = [
    "d /var/lib/hindsight/data 0777 root root -"
  ];

  # Open firewall for the API port if remote access is ever needed
  # (Currently bound to 127.0.0.1 only, so no firewall rule required)
  # networking.firewall.allowedTCPPorts = [ apiPort ];
}
