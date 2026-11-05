{ inputs, config, ... }:

# System-level secrets shared by laptop and desktop (see the importing
# hosts' configuration.nix). Everything here is user-scoped and moves
# with the user, so it lives in the shared secrets/common.json instead
# of a per-host file. Encrypted to all personal-machine keys + recovery
# via .sops.yaml at the repo root.
{
  imports = [ inputs.sops-nix.nixosModules.sops ];

  sops = {
    defaultSopsFile = ../secrets/common.json;
    age.keyFile = "/home/${config.users.users.${config.var.username}.name}/.config/sops/age/keys.txt";

    secrets."hermes-env" = {
      format = "json";
    };

    secrets."searxng-env" = {
      format = "json";
    };

    secrets."hindsight-env" = {
      format = "json";
    };

    # Used by nixos/netbird.nix to auto-login the daemon without SSO.
    # Setup keys are not machine-specific, hence part of the shared file.
    secrets."netbird-setup-key" = {
      format = "json";
      owner = "root";
      group = "root";
      mode = "0400";
    };
  };
}
