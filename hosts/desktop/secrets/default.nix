# Those are my secrets, encrypted with sops
# You shouldn't import this file, unless you edit it
{
  pkgs,
  inputs,
  config,
  ...
}: let
  username = config.var.username;
in {
  imports = [inputs.sops-nix.homeManagerModules.sops];

  sops = {
    age.keyFile = "/home/${username}/.config/sops/age/keys.txt";
    defaultSopsFile = ./secrets.yaml;
    secrets = {
      sshconfig = {path = "/home/${username}/.ssh/config";};
      github-key = {path = "/home/${username}/.ssh/github/id_ed25519";};
      gitlab-uni-key = {path = "/home/${username}/.ssh/gitlab_uni/id_ed25519";};
      website-key = {path = "/home/${username}/.gnupg/signing-key.asc";};
      website-pub-key = {path = "/home/${username}/.gnupg/signing-key-pub.asc";};
    };
  };

  home.file.".config/nixos/.sops.yaml".text = ''
    keys:
      - &primary age15wmx8wx7z8llrp8j9t6094xt594j0rnxt6prftjeyfcqjcj6vs3spupn3k
    creation_rules:
      - path_regex: hosts/desktop/secrets/secrets.yaml$
        key_groups:
          - age:
            - *primary
  '';

  systemd.user.services.mbsync.Unit.After = ["sops-nix.service"];
  home.packages = with pkgs; [sops age];

  wayland.windowManager.hyprland.settings.exec-once = ["systemctl --user start sops-nix"];
}
