# Source: https://voidcruiser.nl/rambles/i2p-on-nixos/
# For hosting see: https://mdleom.com/blog/2020/03/21/i2p-eepsite-nixos/
# More info:
# - https://landchad.net/i2p/
# - https://mdleom.com/blog/2020/03/21/i2p-eepsite-nixos/
# - https://comfy.guide/server/i2p-daemon/
{ config, pkgs, ... }: let
  domain = config.var.domain;
in {
  containers.i2pd-container = {
    autoStart = true;

    config = { config, pkgs, ... }: {
      system.stateVersion = "25.11"; # If you don't add a state version, nix will complain at every rebuild

      environment.systemPackages = with pkgs; [
        i2pd-tools
        i2pd
      ];

      # Exposing the nessecary ports in order to interact with i2p from outside the container
      networking.firewall.allowedTCPPorts = [
        7656 # default sam port
        7070 # default web interface port
        4447 # default socks proxy port
        4444 # default http proxy port
        1234 # Inbound port NTCP2
        8081 # For running eepsite
        8082
      ];

      networking.firewall.allowedUDPPorts = [
        1234 # inbound port: SSU2
      ];

      services.i2pd = {
        enable = true;

        # nixpkgs 26.11 rewrote the module: everything now goes through
        # `settings` (verbatim i2pd.conf keys) and inTunnels → serverTunnels.
        settings = {
          host = "0.0.0.0"; # router bind address (was services.i2pd.address)
          port = 1234; # port for incoming connections
          bandwidth = 200; # In KBps

          http = {
            address = "0.0.0.0"; # Anybody localy can conenct to it.
            strictheaders = false; # Careful with this one
          };

          httpproxy.address = "0.0.0.0";

          socksproxy.enabled = true;
          sam.enabled = true;
        };

        # My website mirrored to i2p
        # To register your website in a registrar, enter the container `sudo machinectl shell i2pd-container`
        # and then do `regaddr \var\lib\i2pd\myEep-keys.dat example-domain.2ip > auth_string.txt` this gives yo uthe authenticaiton key with which you can register at reg.i2p
        # To access this file easily I recommend `cat auth.txt | nc termbin.com 9999`
        serverTunnels.myEep = {
          keys = "myEep-keys.dat";
          inport = 8081; # I2P-side port
          host = "127.0.0.1";
          port = 8082; # local service port (nginx below)
        };
      };

      services.nginx = {
        enable = true;

        virtualHosts."localhost" = {
          listen = [{ addr = "0.0.0.0"; port = 8082; }];
          locations."/" = {
            proxyPass = "https://monkemanx.github.io";
          };
          extraConfig = ''
            proxy_set_header Host monkemanx.github.io;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;

            proxy_redirect off;
            proxy_ssl_server_name on;
          '';
        };
      };
    };
  };

  # Expose the ports outside the machine
  networking.firewall.allowedTCPPorts = [
    # 7656
    7070
    # 4447
    4444
    1234
  ];
  networking.firewall.allowedUDPPorts = [
    1234 # inbound port: SSU2
  ];
}
