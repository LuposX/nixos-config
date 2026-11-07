{ inputs, config, ... }:

# System-level secrets shared by laptop and desktop (see the importing
# hosts' configuration.nix). Everything here is user-scoped and moves
# with the user, so it lives in the shared secrets/common.yaml instead
# of a per-host file. Encrypted to all personal-machine keys + recovery
# via .sops.yaml at the repo root.
{
  imports = [ inputs.sops-nix.nixosModules.sops ];

  sops = {
    defaultSopsFile = ../secrets/common.yaml;
    age.keyFile = "/home/${config.users.users.${config.var.username}.name}/.config/sops/age/keys.txt";

    secrets."hermes-env" = {
      format = "yaml";
    };

    secrets."searxng-env" = {
      format = "yaml";
    };

    secrets."hindsight-env" = {
      format = "yaml";
    };

    # Login password hash (mkpasswd -m sha-512), consumed by
    # nixos/users.nix on the hosts that import this module.
    # neededForUsers so the file exists before the users.users
    # activation runs.
    secrets."user-password" = {
      format = "yaml";
      neededForUsers = true;
      owner = "root";
      group = "root";
      mode = "0400";
    };

    secrets."netbird-setup-key" = {
      format = "yaml";
      owner = "root";
      group = "root";
      mode = "0400";
    };
  };
}
