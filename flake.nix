{
  description = "A simple NixOS flake";

  inputs = {
    # NixOS official package source, using the nixos-25.05 branch here
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    # Used for managing a user environment 
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # This is for Neovim
    nvf.url = "github:notashelf/nvf";
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    # Please replace my-nixos with your hostname
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        {
        # With this other Modules will have acess to the inputs
            _module.args = { inherit inputs; };
        }
        inputs.home-manager.nixosModules.home-manager
        ./hosts/desktop/configuration.nix
      ];
    };
  };
}
