# Netbird does have a nix module, but I couldnt find out how to make it work with a setup key file, thus i switched to docker.
{ config, pkgs, ... }: let
  hostname = config.var.hostname;
in {
  virtualisation.docker.enable = true;

  systemd.services.netbird-docker = {
    description = "Netbird client in Docker";
    after = [ "network-online.target" "docker.service" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      ExecStart = ''
        ${pkgs.docker}/bin/docker run \
          --network host \
          --privileged \
          --rm \
          --name netbird-client-${hostname} \
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

  # Make sure Docker is pulled during activation (optional)
  system.activationScripts.pullNetbirdImage = ''
    ${pkgs.docker}/bin/docker pull netbirdio/netbird:latest || true
  '';

  networking.firewall.allowedTCPPorts = [
    443
  ];
  networking.firewall.allowedUDPPorts = [
    80
    443
    3478
    5555
  ];
}
