{
  pkgs,
  config,
  inputs,
  ...
}: {
  imports = [
       # Programs
    ../../home/programs/nvf
    ../../home/programs/shell
    ../../home/programs/git
    ../../home/programs/lazygit
    ../../home/programs/ssh
  ];

  home = {
    inherit (config.var) username;
    homeDirectory = "/home/" + config.var.username;

    packages = with pkgs; [
      inputs.nvix.packages.${pkgs.system}.corae

       # Utils
      zip
      unzip
      btop
      nerdfetch
      wget
    ];

    # Don't touch this
    stateVersion = "25.11";
  };

  programs.home-manager.enable = true;
}
