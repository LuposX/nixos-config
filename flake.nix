{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-26.05";

    stylix = {
      url = "github:make-42/stylix/matugen";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix.url = "github:Mic92/sops-nix";
    nur.url = "github:nix-community/NUR";
    matugen.url = "github:InioX/matugen";

    pi = {
      url = "github:earendil-works/pi/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vicinae.url = "github:vicinaehq/vicinae";

    # v5 (native shell, no quickshell). Pin to the cachix branch so every
    # commit is prebuilt; `follows` would change the derivation hash and break
    # the binary cache.
    noctalia.url = "github:noctalia-dev/noctalia/cachix";

    nix-colors.url = "github:misterio77/nix-colors";

    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zjstatus.url = "github:dj95/zjstatus";

    nvix.url = "github:niksingh710/nvix";

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-stable,
    ...
  } @ inputs: let
    system = "x86_64-linux";
  in {
    nixosConfigurations = {
      logos = nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = {inherit inputs;};

        modules = [
          inputs.sops-nix.nixosModules.sops
          inputs.home-manager.nixosModules.home-manager
          inputs.stylix.nixosModules.stylix
          ./hosts/desktop/configuration.nix
        ];
      };

      pneuma = nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = {inherit inputs;};

        modules = [
          inputs.sops-nix.nixosModules.sops
          inputs.sops-nix.nixosModules.sops
          inputs.home-manager.nixosModules.home-manager
          inputs.stylix.nixosModules.stylix
          ./hosts/laptop/configuration.nix
        ];
      };

      prohairesis = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";

        specialArgs = {inherit inputs;};

        modules = [
          inputs.sops-nix.nixosModules.sops
          inputs.home-manager.nixosModules.home-manager
          ./hosts/raspberry/configuration.nix
        ];
      };
    };
  };
}
