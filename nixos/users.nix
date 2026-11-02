{ config, pkgs, ... }:
let username = config.var.username;
in {
  users = {
    defaultUserShell = pkgs.bash;
    users.${username} = {
      isNormalUser = true;
      description = "${username} account";
      initialPassword = "changeme-nixos";
      extraGroups = [ "networkmanager" "wheel" "video" "render" ];
      # fish as login shell, so SSH sessions get the full interactive
      # setup (starship, fzf, ...) instead of bash
      shell = pkgs.fish;
    };
  };

  # register fish in /etc/shells and the system path so sshd/login accept it
  programs.fish.enable = true;
}
