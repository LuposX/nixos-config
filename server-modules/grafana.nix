{ config, pkgs, ... }: let
  domain = config.var.domain;
in {
  # grafana configuration
  services.grafana = {
    enable = true;
    addr = "127.0.0.1";
    settings.server = {
      http_port = 2342;
      domain = "grafana.${domain}";
    };
    settings.security.secret_key = "SW2YcwTIb9zpOOhoPsMm";
  };

  services.nginx.virtualHosts."grafana.${domain}" = {
    useACMEHost = "idk-this-is-test.duckdns.org";
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:2342";
      proxyWebsockets = true;
      recommendedProxySettings = true;
    };
  };

  networking.firewall.allowedTCPPorts = [ 2342 ];
}
