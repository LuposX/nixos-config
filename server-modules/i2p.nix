# Source: https://voidcruiser.nl/rambles/i2p-on-nixos/
{ ... }: {
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
        proto = {
          http.enable = true;
          socksProxy.enable = true;
          httpProxy.enable = true;
          sam.enable = true;
        };
      };
    };
  };
}
