# Command to install: sudo nixos-rebuild switch --flake .#lupos
# To update: nix flake update 
#
# Install on fresh pc
# 1. sudo su
# 2. nix-env -iA nixos.git # to install git
# 3. git clone <your_repo>
# 4. nixos-install --flake .#<host>
# 5. reboot
# 6. sudo rm -r /etc/nixos/configuration.nix # delete default config
#
{
  description = "NixOS Config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware/master";

    # Official Hyprland Flake
    hyprland = {
      url = "github:hyprwm/Hyprland";
    };

    # Hyprland plugins
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

    # Hyprspace
    hyprspace = {
      url = "github:KZDKM/Hyprspace";
      inputs.hyprland.follows = "hyprland";
    };
    
    # Hyprpanel
    hyprpanel = {
      url = "github:Jas-SinghFSU/HyprPanel";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Neovim
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };  

    # Emacs Overlays
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      flake = false;
    };

    # Nix-Community Doom Emacs
    doom-emacs = {
      url = "github:nix-community/nix-doom-emacs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.emacs-overlay.follows = "emacs-overlay";
    };  

    # Nixcord
    nixcord = {
      url = "github:kaylorben/nixcord";
    };

    # Home Manager Package Management
    home-manager = {
      url = "github:nix-community/home-manager";
      # Else home-manager will use its own pkgs,
      # home manager gets less frequent updated.
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { self, nixpkgs, nixos-hardware, home-manager, nixvim, doom-emacs, hyprland, hyprspace, hyprpanel, nixcord, ... }: 
    let 
      # Variables Used in Flake
      vars = {
        system = "x86_64-linux";
        user = "lupos";
        location = "$HOME/.nixos-config";
        terminal = "kitty";
        editor = "nvim";
      };
    in {
        nixosConfigurations = (
        import ./hosts {
          inherit (nixpkgs) lib;
          inherit inputs nixpkgs nixos-hardware home-manager nixvim doom-emacs hyprland hyprspace hyprpanel nixcord vars; # Inherit inputs
        }
      );
    };
}

