{ inputs, pkgs, ... }: {
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-backup";

    extraSpecialArgs = {
      inherit inputs;

      pkgsStable = import inputs.nixpkgs-stable {
        system = pkgs.stdenv.hostPlatform.system; # pkgs.system is a deprecated alias
        config.allowUnfree = true;
      };
    };
  };
}
