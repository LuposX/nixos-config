{ pkgs, config, ... }: {

  imports = [
    ./variables.nix
  ];
  
  home = {
    packages = with pkgs; [
        inherit (config.var) username;
        homeDirectory = "/home/" = config.var.username;
    ];

    # Don't touch this
    stateVersion = "25.05";
  };

  programs.home-manager.enable = true;
}
