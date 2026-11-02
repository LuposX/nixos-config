{
  pkgs,
  lib,
  ...
}: let
  setupKeyFile = "/run/secrets/netbird-setup-key";
in {
  services.netbird.enable = true; # for netbird service & CLI
  environment.systemPackages = [pkgs.netbird-ui]; # for GUI

  # Auto-login the daemon with a setup key so hosts come back online
  # without interactive SSO (SSO sessions expire and leave the peer
  # stranded in "Idle" / "NeedsLogin" until someone runs `netbird up`).
  # A registered setup key persists in /var/lib/netbird, so this only
  # runs when the daemon is actually logged out.
  systemd.services.netbird-login = {
    description = "NetBird auto-login with setup key";
    after = ["netbird.service" "sops-nix.service"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      if [ ! -f ${setupKeyFile} ]; then
        echo "no ${setupKeyFile}, skipping netbird auto-login"
        exit 0
      fi
      # Wait for the daemon socket (max ~30s)
      for i in $(seq 1 30); do
        ${pkgs.netbird}/bin/netbird status >/dev/null 2>&1 && break
        sleep 1
      done
      if ${pkgs.netbird}/bin/netbird status | grep -q "NeedsLogin"; then
        ${pkgs.netbird}/bin/netbird up --setup-key "$(cat ${setupKeyFile})"
      else
        echo "netbird already logged in"
      fi
    '';
  };
}
