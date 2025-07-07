{ config, pkgs, ... }: let
  domain = config.var.domain;
in {
  networking.enableIPv6 = true;

  # Prometheus server
  services.prometheus = {
    enable = true;
    port = 9001;

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
      {
        # Uses Script From Script Libarz from Shelly Plug S
        job_name = "shelly-plus-plug";
        metrics_path = "/script/2/metrics";
        static_configs = [{
          targets = [ "192.168.12.88" ];
        }];
      }
    ];
  };

  # Nginx proxy to Prometheus
  services.nginx.virtualHosts."prometheus.${domain}" = {
    useACMEHost = "idk-this-is-test.duckdns.org";
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.prometheus.port}";
      proxyWebsockets = true;
      recommendedProxySettings = true;
    };
  };

  networking.firewall.allowedTCPPorts = [ 9001 10009 5353 ]; # added 10009 for exporter port, 5353 is mdns port
}
