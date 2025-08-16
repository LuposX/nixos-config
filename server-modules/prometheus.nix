{ config, pkgs, ... }:

let
  domain = config.var.domain;

  i2pdExporter = pkgs.stdenv.mkDerivation {
    name = "i2pd-webconsole-exporter";
    src = pkgs.fetchurl {
      url = "https://github.com/Jercik/i2pd-exporter/releases/download/v1.3.0/i2pd-exporter-aarch64-unknown-linux-gnu.tar.gz";
      sha256 = "sha256-fiRiZOOiiVeLZ/qtO3GdeHDcLOMzZ0aZjIm3GF3dtdg=";
    };
    phases = [ "unpackPhase" "installPhase" ];
    unpackPhase = "tar xzf $src";
    installPhase = ''
      mkdir -p $out/bin
      cp i2pd-exporter $out/bin/
    '';
  };

in {
  networking.enableIPv6 = true;

  # Firewall: open Prometheus, Shelly exporter, mDNS, and i2pd exporter
  networking.firewall.allowedTCPPorts = [ 9001 10009 5353 9447 ];

  # Prometheus Server
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
        job_name = "shelly-plus-plug";
        metrics_path = "/script/2/metrics";
        static_configs = [{
          targets = [ "192.168.12.88" ];
        }];
      }
      {
        job_name = "i2pd";
        static_configs = [{
          targets = [ "127.0.0.1:9447" ];
        }];
      }
    ];
  };

  # i2pd webconsole exporter systemd service
  systemd.services.i2pd-webconsole-exporter = {
    description = "I2Pd Web Metrics Exporter";
    wantedBy = [ "multi-user.target" ];
    after = [ "i2pd.service" ];
    requires = [ "i2pd.service" ];

    serviceConfig = {
      ExecStart = "${i2pdExporter}/bin/i2pd-exporter";
      Environment = [
        "I2PD_WEB_CONSOLE=http://127.0.0.1:7070"
        "METRICS_LISTEN_ADDR=0.0.0.0:9447"
        "RUST_LOG=info"
      ];
      Restart = "on-failure";
      RestartSec = 10;
      User = "i2pd";
      Group = "i2pd";
    };
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

  # Optional: add exporter binary to PATH
  environment.systemPackages = [ i2pdExporter ];
}
