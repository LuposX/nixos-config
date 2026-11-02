{ inputs, config, ... }:

{
  imports = [ inputs.sops-nix.nixosModules.sops ];

  sops = {
    defaultSopsFile = ../hosts/desktop/secrets/secrets.yaml; # or per-host
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

    # Used by nixos/netbird.nix to auto-login the daemon without SSO.
    secrets."netbird-setup-key" = {
      format = "yaml";
      owner = "root";
      group = "root";
      mode = "0400";
    };
  };
}
