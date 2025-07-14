{ config, ... }: let
  domain = config.var.domain;
in {
  services.nginx = {
    enable = true;
    commonHttpConfig = ''
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;
    '';
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = config.var.git.email;
  };

  security.acme.certs."${domain}" = {
    domain = "${domain}";
    extraDomainNames = [ "*.${domain}" ];
    group = "nginx";

    dnsProvider = "duckdns";
    dnsPropagationCheck = true;
    credentialsFile = config.sops.secrets.duckdns-dns-token.path;
  };

  services.nginx.virtualHosts = {
    # Acts as "catch-all" server that drops unwanted traffic
    "default" = {
      default = true;
      locations."/" = { return = 444; };
    };
    # Block wildcard access unless explicitly allowed
    "*.${domain}" = {
      useACMEHost = "${domain}";
      forceSSL = true;
      locations."/" = { return = 444; };
    };
    # Glance
    "${domain}" = {
      useACMEHost = "${domain}";
      forceSSL = true;
      locations."/" = {
        proxyPass =
          "http://192.168.12.100:5678";
      };
    };
    "audiobook.${domain}" = {
      useACMEHost = "${domain}";
      forceSSL = true;
      locations."/" = {
        proxyPass =
          "http://192.168.12.49:13378";
      };
    };
    "calibre.${domain}" = {
      useACMEHost = "${domain}";
      forceSSL = true;
      locations."/" = {
        proxyPass =
          "http://192.168.12.49:8084";
      };
    };
    "gotify.${domain}" = {
      useACMEHost = "${domain}";
      forceSSL = true;
      locations."/" = {
        proxyPass =
          "http://192.168.12.144:80";
      };
    };
    "immich.${domain}" = {
      useACMEHost = "${domain}";
      forceSSL = true;
      locations."/" = {
        proxyPass =
          "http://192.168.12.133:2283";
      };
    };
    "jellyfin.${domain}" = {
      useACMEHost = "${domain}";
      forceSSL = true;
      locations."/" = {
        proxyPass =
          "http://192.168.12.145:8096";
      };
    };
    "jellystat.${domain}" = {
      useACMEHost = "${domain}";
      forceSSL = true;
      locations."/" = {
        proxyPass =
          "http://192.168.12.196:3000";
      };
    };
    "jellywatch.${domain}" = {
      useACMEHost = "${domain}";
      forceSSL = true;
      locations."/" = {
        proxyPass =
          "http://192.168.12.196:5057";
      };
    };
    "paper.${domain}" = {
      useACMEHost = "${domain}";
      forceSSL = true;
      locations."/" = {
        proxyPass =
          "http://192.168.12.130:8000";
      };
    };
    "nas.${domain}" = {
      useACMEHost = "${domain}";
      forceSSL = true;
      locations."/" = {
        proxyPass =
          "http://192.168.12.92:80";
      };
    };
    "prowlarr.${domain}" = {
      useACMEHost = "${domain}";
      forceSSL = true;
      locations."/" = {
        proxyPass =
          "http://192.168.12.109:9696";
      };
    };
    "prox.${domain}" = {
      useACMEHost = "${domain}";
      forceSSL = true;
      locations."/" = {
        proxyPass =
          "http://192.168.12.10:8006";
      };
    };
    "radarr.${domain}" = {
      useACMEHost = "${domain}";
      forceSSL = true;
      locations."/" = {
        proxyPass =
          "http://192.168.12.109:7878";
      };
    };
    "read_prowlarr.${domain}" = {
      useACMEHost = "${domain}";
      forceSSL = true;
      locations."/" = {
        proxyPass =
          "http://192.168.12.49:9696";
      };
    };
    "read_torrent.${domain}" = {
      useACMEHost = "${domain}";
      forceSSL = true;
      locations."/" = {
        proxyPass =
          "http://192.168.12.49:8080";
      };
    };
    "request.${domain}" = {
      useACMEHost = "${domain}";
      forceSSL = true;
      locations."/" = {
        proxyPass =
          "http://192.168.12.110:5055";
      };
    };
    "sonarr.${domain}" = {
      useACMEHost = "${domain}";
      forceSSL = true;
      locations."/" = {
        proxyPass =
          "http://192.168.12.109:8989";
      };
    };
    "syncthing.${domain}" = {
      useACMEHost = "${domain}";
      forceSSL = true;
      locations."/" = {
        proxyPass =
          "http://192.168.12.116:8384";
      };
    };
    "tandoor.${domain}" = {
      useACMEHost = "${domain}";
      forceSSL = true;
      locations."/" = {
        proxyPass =
          "http://192.168.12.127:8002";
      };
    };
    "torrent.${domain}" = {
      useACMEHost = "${domain}";
      forceSSL = true;
      locations."/" = {
        proxyPass =
          "http://192.168.12.109:8085";
      };
    };
    "vault.${domain}" = {
      useACMEHost = "${domain}";
      forceSSL = true;
      locations."/" = {
        proxyPass =
          "http://192.168.12.89:8000";
      };
    };
    "wg.${domain}" = {
      useACMEHost = "${domain}";
      forceSSL = true;
      locations."/" = {
        proxyPass =
          "http://192.168.12.140:51821";
      };
    };
    "i2pd-web.${domain}" = {
      useACMEHost = "${domain}";
      forceSSL = true;
      locations."/" = {
        proxyPass =
          "http://192.168.12.100:7070";
      };
    };
    "i2pd-proxy.${domain}" = {
      useACMEHost = "${domain}";
      forceSSL = true;
      locations."/" = {
        proxyPass =
          "http://192.168.12.100:4444";
      };
    };
    "kvm.${domain}" = {
      useACMEHost = "${domain}";
      forceSSL = true;
      locations."/" = {
        proxyPass =
          "http://192.168.12.51";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
  networking.firewall.allowedUDPPorts = [ 80 443 ];
}
