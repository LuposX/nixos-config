{
  description = "A simple NixOS flake";

  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    # Use the stable for things you dont want to compile e.g. Libre Office
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # ianyrun.url = "github:fufexan/anyrun/launch-prefix";
    # hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1"; # The Desktop.
    # hyprland.url = "github:hyprwm/Hyprland/";  # Switched to Niri
    # hyprpanel.url = "github:Jas-SinghFSU/HyprPanel"; # The Bar in the top. # Switched to Noctalia

    # Theming
    stylix = {
      url = "github:make-42/stylix/matugen";
      # url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };


    sops-nix.url = "github:Mic92/sops-nix"; # Secret Managment

    # hyprpolkitagent.url = "github:hyprwm/hyprpolkitagent";  # Switched to Niri
    nur.url = "github:nix-community/NUR";
    matugen.url = "github:InioX/matugen";
     nixmate.url = "github:daskladas/nixmate";

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vicinae.url = "github:vicinaehq/vicinae";
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-colors.url = "github:misterio77/nix-colors";

    # nvf.url = "github:notashelf/nvf"; # This is for Neovim

# Csuotm Status bar for zellij
    zjstatus = {
      url = "github:dj95/zjstatus";
     };

    # My own fork, for easier changes.
    nvix.url = "github:LuposX/nvix";

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Used for managing a user environment
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Gives Overview over Workspaces.
    # See: https://github.com/raybbian/hyprtasking/pull/73
    # hyprtasking = {
    #   url = "github:raybbian/hyprtasking";
    #   inputs.hyprland.follows = "hyprland";
    #   # url = "github:r00t3g/hyprtasking/9388b8ca1bd53a5bfa89b1a6caec7a801df0b6aa";
    #   # inputs.hyprland.follows = "hyprland";
    # };  # Switched to Niri

    # Spotify
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: {
    nixosConfigurations = {
      # My Desktop Pc
      logos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          {
            # With this other Modules will have access to the inputs
            _module.args = {inherit inputs;};
          }
          inputs.sops-nix.nixosModules.sops
          inputs.home-manager.nixosModules.home-manager
          inputs.stylix.nixosModules.stylix
          ./hosts/desktop/configuration.nix
        ];
      };
      # My Laptop
      pneuma = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          {
            # With this other Modules will have access to the inputs
            _module.args = {inherit inputs;};
          }

          inputs.sops-nix.nixosModules.sops
          inputs.home-manager.nixosModules.home-manager
          inputs.stylix.nixosModules.stylix
          ./hosts/laptop/configuration.nix
        ];
      };
      # My Rasperry Pi
      prohairesis = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          {
            # With this other Modules will have access to the inputs
            _module.args = {inherit inputs;};
          }
          inputs.sops-nix.nixosModules.sops
          inputs.home-manager.nixosModules.home-manager
          ./hosts/raspberry/configuration.nix
        ];
      };
    };
  };
}
