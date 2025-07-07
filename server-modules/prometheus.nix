{ config, pkgs, ... }: let
  domain = config.var.domain;
in {
  # Server
  services.prometheus = {
    enable = true;
    port = 9001;
  };

  # Client
  services.prometheus = {
    exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
        port = 9002;
      };
    };
    scrapeConfigs = [
      {
        job_name = "node_prohairesis";
        static_configs = [{
          targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ];
        }];
      }
    ];
  };



  services.nginx.virtualHosts."prometheus.${domain}" = {
    useACMEHost = "idk-this-is-test.duckdns.org";
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.prometheus.port}";
      proxyWebsockets = true;
      recommendedProxySettings = true;
    };
  };

  networking.firewall.allowedTCPPorts = [ 9001 ];
}
