{ config, pkgs, ... }: let
  domain = config.var.domain;
in {
  # grafana configuration
  services.grafana = {
    enable = true;
    domain = "grafana.${domain}";
    port = 2342;
    addr = "127.0.0.1";
  };

  services.nginx.virtualHosts."grafana.${domain}" = {
    useACMEHost = "idk-this-is-test.duckdns.org";
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.grafana.port}";
      proxyWebsockets = true;
      recommendedProxySettings = true;
    };
  };

  networking.firewall.allowedTCPPorts = [ 2342 ];
}
