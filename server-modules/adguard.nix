{ config, ...}: let
  username = config.var.username;
in {
  services.adguardhome = {
    enable = true;
    openFirewall = true;
    port = 3000;
    host = "0.0.0.0";

    settings = {
      statistics.enabled = true;

      rewrites = [
        {
        domain = "home.local";
        answer = (builtins.elemAt config.networking.interfaces.eth0.ipv4.addresses 0).address;
        }
      ];
    };
  };
  networking.firewall.allowedTCPPorts = [ 22 53 3000 ];
  networking.firewall.allowedUDPPorts = [ 53 ];
}
