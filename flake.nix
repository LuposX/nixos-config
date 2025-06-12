{
  description = "A simple NixOS flake";

  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    anyrun.url = "github:fufexan/anyrun/launch-prefix";
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1"; # The Desktop.
    hyprpanel.url = "github:Jas-SinghFSU/HyprPanel"; # The Bar in the top.
    stylix.url = "github:nix-community/stylix"; # Theming
    sops-nix.url = "github:Mic92/sops-nix"; # Secret Managment

    # nvf.url = "github:notashelf/nvf"; # This is for Neovim
    
    # My own fork, for easier changes.
    nvix.url = "github:LuposX/nvix";

    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Used for managing a user environment
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # This fixes the bug, when a command is not found.
    flake-programs-sqlite = {
      url = "github:wamserma/flake-programs-sqlite";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Gives Overview over Workspaces.
    hyprtasking = {
      url = "github:raybbian/hyprtasking";
      inputs.hyprland.follows = "hyprland";
    };

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
    # Please replace my-nixos with your hostname
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        {
          nixpkgs.overlays = [inputs.hyprpanel.overlay];
          # With this other Modules will have acess to the inputs
          _module.args = {inherit inputs;};
        }
        inputs.sops-nix.nixosModules.sops
        inputs.flake-programs-sqlite.nixosModules.programs-sqlite
        inputs.home-manager.nixosModules.home-manager
        inputs.stylix.nixosModules.stylix
        ./hosts/desktop/configuration.nix
      ];
    };
  };
}
