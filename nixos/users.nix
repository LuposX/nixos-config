{ config, pkgs, ... }:
let username = config.var.username;
in {
  users = {
    defaultUserShell = pkgs.bash;
    users.${username} = {
      isNormalUser = true;
      description = "${username} account";
      initialPassword = "changeme-nixos";
      extraGroups = [ "networkmanager" "wheel" ];
    };
  };
}
