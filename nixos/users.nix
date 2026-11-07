{ config, pkgs, ... }:
let username = config.var.username;
in {
  users = {
    defaultUserShell = pkgs.bash;
    # Password comes from the sha-512 hash in secrets/common.yaml
    # (declared in nixos/sops.nix). Raspberry can't decrypt common.yaml,
    # so it falls back to the initial password and keeps mutable users.
    mutableUsers = config.var.isRaspberry;
    users.${username} = {
      isNormalUser = true;
      description = "${username} account";
      initialPassword =
        if config.var.isRaspberry
        then "changeme-nixos"
        else null;
      hashedPasswordFile =
        if config.var.isRaspberry
        then null
        else config.sops.secrets.user-password.path;
      extraGroups = [ "networkmanager" "wheel" "video" "render" ];
      # fish as login shell, so SSH sessions get the full interactive
      # setup (starship, fzf, ...) instead of bash
      shell = pkgs.fish;
    };
  };

  # register fish in /etc/shells and the system path so sshd/login accept it
  programs.fish.enable = true;
}
