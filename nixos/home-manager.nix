{ inputs, pkgs, ... }: {
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-backup";

    extraSpecialArgs = {
      inherit inputs;

      pkgsStable = import inputs.nixpkgs-stable {
        system = pkgs.system;
        config.allowUnfree = true;
      };
    };
  };
}
