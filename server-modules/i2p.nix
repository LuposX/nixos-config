# Source: https://voidcruiser.nl/rambles/i2p-on-nixos/
# For hosting see: https://mdleom.com/blog/2020/03/21/i2p-eepsite-nixos/
{ config, ... }: let
  domain = config.var.domain;
in {
  containers.i2pd-container = {
    autoStart = true;
    config = { config, ... }: {

      system.stateVersion = "25.11"; # If you don't add a state version, nix will complain at every rebuild

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
          http.address = "0.0.0.0"; # Anybody localy can conenct to it.
          http.strictHeaders = false; # Careful with this one

          httpProxy.enable = true;
          httpProxy.address = "0.0.0.0";

          socksProxy.enable = true;
          sam.enable = true;
        };
      };

      # Route all trafic that goes external through a VPN and all local traffic not
      # I do this so, I do not need to port forward anything.
      networking.useDHCP = true;
      networking.wg-quick.interfaces.vpn0 = {
        address = [ "10.164.125.229/32" "fd7d:76ee:e68f:a993:d9b1:f36a:cba3:1200/128" ];
        privateKeyFile = "/etc/wireguard/privatekey";
        mtu = 1320;
        dns = [ "10.128.0.1" "fd7d:76ee:e68f:a993::1" ];

        peers = [{
          publicKey = "PyLCXAQT8KkM4T+dUsOQfn+Ub3pGxfGlxkIApuig+hk=";
          presharedKeyFile = "/etc/wireguard/presharedkey";
          # Exclude local traffic
          # See: https://www.procustodibus.com/blog/2021/03/wireguard-allowedips-calculator/
          allowedIPs = [
            # IPv4 public ranges (excludes private/reserved)
            "0.0.0.0/5"
            "8.0.0.0/7"
            "11.0.0.0/8"
            "12.0.0.0/6"
            "16.0.0.0/4"
            "32.0.0.0/3"
            "64.0.0.0/2"
            "128.0.0.0/3"
            "160.0.0.0/5"
            "168.0.0.0/6"
            "172.0.0.0/12"
            "172.32.0.0/11"
            "172.64.0.0/10"
            "172.128.0.0/9"
            "173.0.0.0/8"
            "174.0.0.0/7"
            "176.0.0.0/4"
            "192.0.0.0/9"
            "192.128.0.0/11"
            "192.160.0.0/13"
            "192.169.0.0/16"
            "192.170.0.0/15"
            "192.172.0.0/14"
            "192.176.0.0/12"
            "192.192.0.0/10"
            "193.0.0.0/8"
            "194.0.0.0/7"
            "196.0.0.0/6"
            "200.0.0.0/5"
            "208.0.0.0/4"
            "224.0.0.0/3"

            # IPv6 global unicast ranges
            "::/1"
            "8000::/2"
            "c000::/3"
            "e000::/4"
            "f000::/5"
            "f800::/6"
            "fe00::/9"
          ];
          endpoint = "46.183.218.148:1637";
          persistentKeepalive = 15;
        }];
        autostart = true;
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
