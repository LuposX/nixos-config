# Source: https://voidcruiser.nl/rambles/i2p-on-nixos/
{ config, ... }: let
  domain = config.var.domain;
in {
  containers.i2pd-container = {
    autoStart = true;
    config = { ... }: {

      system.stateVersion = "23.05"; # If you don't add a state version, nix will complain at every rebuild

      # Exposing the nessecary ports in order to interact with i2p from outside the container
      networking.firewall.allowedTCPPorts = [
        7656 # default sam port
        7070 # default web interface port
        4447 # default socks proxy port
        4444 # default http proxy port
      ];

      services.i2pd = {
        enable = true;
        address = "0.0.0.0";
        bandwidth = 100; # In KBps
        proto = {
          http.enable = true;
          http.address = "0.0.0.0";
          http.strictHeaders = false; # Careful with this one
          socksProxy.enable = true;
          httpProxy.enable = true;
          sam.enable = true;
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
  ];
}
