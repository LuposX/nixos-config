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
    };
  };

  home.file.".config/nixos/.sops.yaml".text = ''
    keys:
      - &primary age15wmx8wx7z8llrp8j9t6094xt594j0rnxt6prftjeyfcqjcj6vs3spupn3k
    creation_rules:
      - path_regex: hosts/raspberry/secrets/secrets.yaml$
        key_groups:
          - age:
            - *primary
  '';

  systemd.user.services.mbsync.Unit.After = ["sops-nix.service"];
  home.packages = with pkgs; [sops age];
}
