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
  };
}
