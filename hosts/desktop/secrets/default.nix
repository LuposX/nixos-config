# Those are my secrets, encrypted with sops
# You shouldn't import this file, unless you edit it
#
# Layout: secrets that follow the user across hosts live in the repo-wide
# secrets/common.json (encrypted to all personal machines + recovery, see
# .sops.yaml at the repo root). This host file keeps only what is bound to
# this machine. The age key for this host is ~/.config/sops/age/keys.txt.
{
  pkgs,
  inputs,
  config,
  ...
}: let
  username = config.var.username;
  common = ../../../secrets/common.json;
in {
  imports = [inputs.sops-nix.homeManagerModules.sops];

  sops = {
    age.keyFile = "/home/${username}/.config/sops/age/keys.txt";
    defaultSopsFile = ./secrets.yaml;

    secrets = {
      # Shared file
      github-key-personal = {
        sopsFile = common;
        format = "json";
        path = "/home/${username}/.ssh/github_personal/id_ed25519";
      };
      github-key-website = {
        sopsFile = common;
        format = "json";
        path = "/home/${username}/.ssh/github_website/id_ed25519";
      };
      gitlab-uni-key = {
        sopsFile = common;
        format = "json";
        path = "/home/${username}/.ssh/gitlab_uni/id_ed25519";
      };
      website-key-pgp = {
        sopsFile = common;
        format = "json";
        path = "/home/${username}/.gnupg/signing-key.asc";
      };
      website-key-pgp-pub = {
        sopsFile = common;
        format = "json";
        path = "/home/${username}/.gnupg/signing-key-pub.asc";
      };
      weather-api = {
        sopsFile = common;
        format = "json";
        path = "/home/${username}/.weather_api_key.json";
      };
      smbcredentials = {
        sopsFile = common;
        format = "json";
        path = "/home/${username}/.smbcredentials";
      };

      # This host only
      ssh-logos-pub = {path = "/home/${username}/.ssh/authorized_keys";};
    };
  };

  systemd.user.services.mbsync.Unit.After = ["sops-nix.service"];
  home.packages = with pkgs; [sops age];

  wayland.windowManager.hyprland.settings.exec-once = ["systemctl --user start sops-nix"];
}
