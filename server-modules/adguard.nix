{ config, ...}: let
  username = config.var.username;
  ipAddress = config.var.ipAddress;
in {
  services.adguardhome = {
    enable = true;
    openFirewall = true;
    port = 3000;
    host = "0.0.0.0";

    settings = {
      statistics.enabled = true;

      filtering.rewrites = [
        {
        domain = "home.local";
        answer = ipAddress;
        }
      ];
    };
  };
  networking.firewall.allowedTCPPorts = [ 22 53 3000 ];
  networking.firewall.allowedUDPPorts = [ 53 ];
}
