{ inputs, ... }: {
  imports = [
    inputs.nvf.homeManagerModules.default
  ];

  programs.nvf = {
    enable = true;
    settings = (import ./settings.nix) true;
  };
}

