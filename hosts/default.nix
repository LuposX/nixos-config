# Inspirtation: https://github.com/MatthiasBenaets/nix-config/blob/master/hosts/default.nix

# The #configuration.nix is the same for all host
# If difference host wnat to have different stuff
# use ./desktop, ./laptop

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
in
{
  laptop = lib.nixosSystem {
    system = vars.system;
    specialArgs = {
      inherit inputs pkgs-stable home-manager hyprland hyprpanel hyprspace vars;
    };
    modules = [
      nixvim.nixosModules.nixvim
      ./laptop/default.nix
      ./configuration.nix

      home-manager.nixosModules.home-manager      
      {
        # Optional settings for home-manager
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
      }
    ];
  };
}
