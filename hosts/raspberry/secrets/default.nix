# Those are my secrets, encrypted with sops
# You shouldn't import this file, unless you edit it
{
  pkgs,
  config,
  ...
}: let
  username = config.var.username;
in {
  sops = {
    age.keyFile = "/home/${username}/.config/sops/age/keys.txt";
    defaultSopsFile = ./secrets.yaml;

    secrets = {
      adguard-pwd = {
        group = "glance";
        mode = "0440";  # owner+group can read
      };
      duckdns-dns-token = {path = "/etc/duckdns/dnskey.txt";};

      netbird-setup-key = {
        key = "netbird/setup-keys/netbird-io/${config.var.hostname}";
        owner = "netbird-netbird-io";
        group = "netbird-netbird-io";
        mode = "0440";
      };
    };
  };

  environment.systemPackages = with pkgs; [sops age];
}
