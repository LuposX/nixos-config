# Inspiration: https://github.com/MatthiasBenaets/nix-config/blob/master/hosts/default.nix

# Shared configuration file for all hosts
# Use `./desktop` or `./laptop` for host-specific settings.

{ inputs, nixpkgs, nixpkgs-stable, nixos-hardware, home-manager, nixvim, doom-emacs, hyprland, hyprspace, hyprpanel, nixcord, vars, ... }:

let
  pkgs = import nixpkgs {
    system = vars.system;
    config.allowUnfree = true;
  };

  pkgs-stable = import nixpkgs-stable {
    system = vars.system;
    config.allowUnfree = true;
  };

  lib = nixpkgs.lib;
in {
  laptop = lib.nixosSystem {
    system = vars.system;
    specialArgs = {
      inherit inputs pkgs-stable home-manager hyprland hyprpanel hyprspace vars;
    };
    modules = [
      nixvim.nixosModules.nixvim
      ./laptop/default.nix
      ./configuration.nix
      {
        system.stateVersion = "24.05";
      }
      home-manager.nixosModules.home-manager
      {
        home-manager.stateVersion = "24.05";
        # Optional settings for home-manager
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
      }
    ];
  };
}
