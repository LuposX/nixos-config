{ pkgs, config, ... }: {

  imports = [
    # User-specific Configurations
    ./variables.nix
    
     # Programs
    ../../home/programs/kitty
    ../../home/programs/shell
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
