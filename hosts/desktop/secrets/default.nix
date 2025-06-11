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
      # Config
      sshconfig = {path = "/home/${username}/.ssh/config";};

      # Keys
      github-key-personal = {path = "/home/${username}/.ssh/github_personal/id_ed25519";};
      github-key-website = {path = "/home/${username}/.ssh/github_website/id_ed25519";};
      gitlab-uni-key = {path = "/home/${username}/.ssh/gitlab_uni/id_ed25519";};
      website-key-pgp = {path = "/home/${username}/.gnupg/signing-key.asc";};
      website-key-pgp-pub = {path = "/home/${username}/.gnupg/signing-key-pub.asc";};
      # API
      weather-api = {path = "/home/${username}/.weather_api_key.json";};

      # Credentials
      smbcredentials = {path = "/home/${username}/.smbcredentials";};
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
