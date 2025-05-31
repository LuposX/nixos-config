{ pkgs, config, ... }: {

  imports = [
    ./variables.nix
  ];
  
  home = {
    inherit (config.var) username;
    homeDirectory = "/home/" + config.var.username;

    packages = with pkgs; [
    ];

    # Don't touch this
    stateVersion = "25.05";
  };

  programs.home-manager.enable = true;
}
