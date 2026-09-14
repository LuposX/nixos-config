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
        owner = "root";
        group = "root";
        mode = "0440";
      };
      # Miniflux initial admin user, as a systemd EnvironmentFile
      # (ADMIN_USERNAME / ADMIN_PASSWORD). Read by root before the service
      # drops to its DynamicUser, hence owner-only.
      miniflux-admin-credentials = {
        owner = "root";
        group = "root";
        mode = "0400";
      };
    };
  };

  environment.systemPackages = with pkgs; [sops age];
}
