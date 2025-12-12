# Netbird does have a nix module, but I couldnt find out how to make it work with a setup key file, thus i switched to docker.
{ config, pkgs, ... }:
let
  hostname = config.var.hostname;
in
{
  virtualisation.docker.enable = true;

  # systemd service running NetBird in Docker
  systemd.services.netbird-docker = {
    description = "Netbird client in Docker";
    after = [ "network-online.target" "docker.service" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      # run NetBird container with wg-proxy disabled inside container
      ExecStart = ''
        ${pkgs.docker}/bin/docker run \
          --network host \
          --privileged \
          --rm \
          --name netbird-client-${hostname} \
          -e NB_DISABLE_WG_PROXY=true \
          -e NB_SETUP_KEY_FILE=/run/secrets/netbird-setup-key \
          -v /var/lib/netbird:/etc/netbird \
          -v /run/secrets/netbird-setup-key:/run/secrets/netbird-setup-key:ro \
          netbirdio/netbird:latest
      '';
      ExecStop = "${pkgs.docker}/bin/docker stop netbird-client-${hostname} || true";
    };
  };

  # Ensure the persistent volume directory exists
  systemd.tmpfiles.rules = [
    "d /var/lib/netbird 0700 root root -"
  ];

  # Pull image during activation (optional)
  system.activationScripts.pullNetbirdImage = ''
    ${pkgs.docker}/bin/docker pull netbirdio/netbird:latest || true
  '';

  # If you plan to use this machine as an exit-node, keep ip_forward = 1.
  # If not, you can set it to 0. Leave it enabled only if you actually serve as exit node.
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  networking = {
    # ---- NAT: disable host NAT for NetBird (avoid double-NAT) ----
    nat.enable = false;
    nat.internalInterfaces = [];

    # ---- Firewall: avoid outbound UDP blocking ----
    # NixOS's firewall allows outbound UDP by default. Do not restrict outbound UDP.
    firewall = {
      # keep rp_filter relaxed, useful for multi-homed / VPN setups
      checkReversePath = "loose";

      # Minimal inbound ports only (TCP 443 for admin UI / control if needed)
      allowedTCPPorts = [ 443 ];

      # You can keep WireGuard listen ports open if you want peers to contact you directly
      allowedUDPPorts = [
        3478   # STUN/TURN (commonly used)
        51820  # WireGuard default (optional: open only if you expect inbound)
        51821  # alternate WG port you referenced
      ];

      # IMPORTANT: do NOT add the iptables -t nat MASQUERADE rule you had earlier.
      # That rule rewrites source addresses for 100.71.0.0/16 -> 192.168.12.0/24 and breaks ICE.
      extraCommands = ''
        # no custom NAT rules for NetBird here
      '';
    };
  };
}
