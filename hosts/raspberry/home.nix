{
  pkgs,
  config,
  inputs,
  ...
}: {
  imports = [
    # User-specific Configurations
    ./variables.nix

    # Programs
    ../../home/programs/shell
    ../../home/programs/git
    ../../home/programs/lazygit
    ../../home/programs/ssh
  ];

  home = {
    inherit (config.var) username;
    homeDirectory = "/home/" + config.var.username;

    packages = with pkgs; [
      inputs.nvix.packages.${pkgs.system}.bare

       # Utils
      zip
      unzip
      btop
      nerdfetch
      wget
      dig
    ];

    # Don't touch this
    stateVersion = "25.11";
  };

  programs.home-manager.enable = true;
}
