{ config, ...}: let
  ipAddress = config.var.ipAddress;
  domain = "idk-this-is-test.duckdns.org";
in {
  services = {
    adguardhome = {
      enable = true;
      openFirewall = true;
      port = 3000;
      host = "0.0.0.0";

      settings = {
        statistics.enabled = true;

        filtering.rewrites = [
          {
          domain = "${domain}";
          answer = ipAddress;
          }
          {
          domain = "*.${domain}";
          answer = ipAddress;
          }
        ];
      };
    };
    nginx.virtualHosts."adguard.${domain}" = {
      useACMEHost = "idk-this-is-test.duckdns.org";
      forceSSL = true;
      locations."/" = {
        proxyPass =
          "http://127.0.0.1:${toString config.services.adguardhome.port}";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 22 53 3000 ];
  networking.firewall.allowedUDPPorts = [ 53 ];
}
