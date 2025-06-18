{ config, ...}: let
  username = config.var.username;
in {
  services.adguardhome = {
    enable = true;
    openFirewall = true;
    port = 3000;
    host = "0.0.0.0";

    settings.statistics.enabled = true;
  };
}
